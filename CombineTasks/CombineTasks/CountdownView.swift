//
//  CountdownView.swift
//  CombineTasks
//
//  Created by Anastasiya Omak on 22/05/2024.
//


import SwiftUI
import Combine

struct CountdownView: View {
    @StateObject private var viewModel = CountdownViewModel()

    var body: some View {
        VStack {
            Text("Оставшееся время \(viewModel.timeString)")
                .frame(height: 50)
            Spacer()
            Form {
                switch viewModel.viewState {
                case .initial:
                    EmptyView()
                case .loading:
                    VStack {
                        switch viewModel.currentPhase {
                        case .connectingToServer:
                            VStack {
                                Text("Подключение к серверу...")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .rotationEffect(Angle.degrees(viewModel.rotation))
                                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: false), value: viewModel.rotation)
                                ProgressView()
                            }
                        case .fetchingItems:
                            VStack {
                                Text("Загрузка товаров...")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .scaleEffect(viewModel.scale)
                                    .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: viewModel.scale)
                                ProgressView()
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .loaded(let items):
                    Section(header: Text("")) {
                        List(items, id: \.id) { item in
                            HStack {
                                Image(systemName: item.imageName ?? "")
                                    .frame(width: 20, height: 20)
                                Spacer().frame(width: 20)
                                Text(item.name)
                                    .frame(width: 140, alignment: .leading)
                                Text("\(String(item.price))€")
                            }
                        }
                    }
                case .failed(let error):
                    Text(error.localizedDescription)
                }
            }
            Button("Начать") {
                viewModel.startTimer()
            }
            .frame(height: 50)
        }
    }
}

enum LoadingState<Model> {
    case initial
    case loading
    case loaded(_ data: Model)
    case failed(_ error: Error)
}

enum Phase {
    case connectingToServer
    case fetchingItems
}

struct Product: Identifiable {
    var id = UUID()
    var imageName: String?
    var name: String
    var price: Int
}

class CountdownViewModel: ObservableObject {
    @Published var viewState: LoadingState<[Product]> = .initial
    @Published var currentPhase: Phase = .connectingToServer
    @Published var timeString = ""
    @Published var rotation: Double = 0
    @Published var scale: CGFloat = 1.0

    private var secondsElapsed = 0

    private let timePublisher = PassthroughSubject<String, Never>()
    private var subscriptions = Set<AnyCancellable>()
    private var timerSubscription: AnyCancellable?
    private var rotationAnimationSubscription: AnyCancellable?
    private var scaleAnimationSubscription: AnyCancellable?

    private var products: [Product] = [
        .init(imageName: "airplane", name: "Air plane", price: 100000),
        .init(imageName: "bus", name: "Bus", price: 20000),
        .init(imageName: nil, name: "Scooter", price: 200),
        .init(imageName: "tram", name: "Tram", price: 10000),
        .init(imageName: "ferry", name: "Ferry", price: 30000),
        .init(imageName: "car", name: "Car", price: 5000),
        .init(imageName: "sailboat", name: "Sail Boat", price: 99),
        .init(imageName: "scooter", name: "Scooter", price: 1000),
        .init(imageName: "fuelpump", name: "Fuelpump", price: 99),
        
    ]

    init() {
        setupBindings()
    }

    func startTimer() {
        secondsElapsed = 0
        startCountdown()
        viewState = .loading
        currentPhase = .connectingToServer
        simulateDataLoading()
        initiateRotationAnimation()
    }

    private func setupBindings() {
        timePublisher
            .sink { [weak self] time in
                self?.timeString = time
            }
            .store(in: &subscriptions)
    }

    private func startCountdown() {
        timePublisher.send("00:00")
        timerSubscription = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.secondsElapsed += 1
                let minutes = self.secondsElapsed / 60
                let seconds = self.secondsElapsed % 60
                self.timePublisher.send(String(format: "%02d:%02d", minutes, seconds))
            }
    }

    private func simulateDataLoading() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.currentPhase = .fetchingItems
            self.initiateScaleAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.displayProducts()
            }
        }
    }

    private func initiateRotationAnimation() {
        rotationAnimationSubscription = Timer
            .publish(every: 0.01, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                withAnimation {
                    self.rotation += 1
                }
            }
    }

    private func initiateScaleAnimation() {
        scaleAnimationSubscription = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                withAnimation {
                    self.scale = (self.scale == 1.0) ? 1.2 : 1.0
                }
            }
    }

    private func displayProducts() {
        Just(products)
            .map { items in
                items.filter { $0.price >= 100 && $0.imageName != nil }
            }
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.viewState = .failed(error)
                }
            }, receiveValue: { [weak self] items in
                self?.timerSubscription?.cancel()
                self?.viewState = .loaded(items)
            })
            .store(in: &subscriptions)
    }
}

#Preview {
    CountdownView()
}
