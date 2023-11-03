//
//  ExploreViewController.swift
//  TikTok
//
//  Created by mnash29 on 10/9/23.
//

import UIKit

class ExploreViewController: UIViewController {

    private let searchBar: UISearchBar = {
        let bar = UISearchBar()

        bar.placeholder = "Search..."
        bar.layer.cornerRadius = 8
        bar.layer.masksToBounds = true
        return bar
    }()

    private var sections = [ExploreSection]()

    private var collectionView: UICollectionView?

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()

        view.backgroundColor = .systemBackground
        setUpSearchBar()
        setUpCollectionView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        collectionView?.frame = view.bounds
    }

    func setUpSearchBar() {
        navigationItem.titleView = searchBar
        searchBar.delegate = self
    }

    func configureModels() {
        var cells = [ExploreCell]()
        for _ in 0...100 {
            let cell = ExploreCell.banner(
                viewModel: ExploreBannerViewModel(
                    image: UIImage(named: "test"),
                    title: "Foo",
                    handler: {

                    }
                )
            )
            cells.append(cell)
        }

        var posts = [ExploreCell]()
        for _ in 0...40 {
            posts.append(
                ExploreCell.post(
                    viewModel: ExplorePostViewModel(
                        thumbailImage: UIImage(named: "test"),
                        caption: "This was a really long post and a long caption",
                        handler: {

                        }
                    )
                )
            )
        }

        var usernames = ["kanye", "andy", "tim", "loretta", "matthew", "anna"]
        var users = [ExploreCell]()
        for i in 0...5 {
            users.append(
                ExploreCell.user(
                    viewModel: ExploreUserViewModel(
                        profilePictureURL: nil,
                        username: usernames[i],
                        followerCount: 25,
                        handler: {

                        }
                    )
                )
            )
        }

        sections = [
            ExploreSection(
                type: .banners,
                cells: cells
            ),
            ExploreSection(
                type: .trendingPosts,
                cells: posts
            ),
            ExploreSection(
                type: .users,
                cells: users
            ),
            ExploreSection(
                type: .trendingHashtags,
                cells: [
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: UIImage(systemName: "house"),
                        text: "#foryou",
                        count: 1,
                        handler: {

                        })),
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: UIImage(systemName: "airplane"),
                        text: "#iphone12",
                        count: 1,
                        handler: {

                        })),
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: UIImage(systemName: "camera"),
                        text: "#tiktokcourse",
                        count: 1,
                        handler: {

                        })),
                    .hashtag(viewModel: ExploreHashtagViewModel(
                        icon: UIImage(systemName: "bell"),
                        text: "#m1Macbook",
                        count: 1,
                        handler: {

                        })),
                ]
            ),
            ExploreSection(
                type: .recommended,
                cells: posts
            ),
            ExploreSection(
                type: .popular,
                cells: posts
            ),
            ExploreSection(
                type: .new,
                cells: posts
            ),
        ]
    }

    func setUpCollectionView() {
        let layout = UICollectionViewCompositionalLayout { section, _ -> NSCollectionLayoutSection? in
            return self.layout(for: section)
        }

        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: layout
        )

        collectionView.register(
            ExploreBannerCollectionViewCell.self,
            forCellWithReuseIdentifier: ExploreBannerCollectionViewCell.identifier
        )
        collectionView.register(
            ExplorePostCollectionViewCell.self,
            forCellWithReuseIdentifier: ExplorePostCollectionViewCell.identifier
        )
        collectionView.register(
            ExploreUserCollectionViewCell.self,
            forCellWithReuseIdentifier: ExploreUserCollectionViewCell.identifier
        )
        collectionView.register(
            ExploreHashtagCollectionViewCell.self,
            forCellWithReuseIdentifier: ExploreHashtagCollectionViewCell.identifier
        )
        collectionView.register(
            UICollectionViewCell.self,
            forCellWithReuseIdentifier: "cell"
        )

        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)

        self.collectionView = collectionView
    }

}

// MARK: - UISearchBar delegate methods

extension ExploreViewController: UISearchBarDelegate {

}

// MARK: - UICollectionView delegate and datasource methods

extension ExploreViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sections[section].cells.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let model: ExploreCell = sections[indexPath.section].cells[indexPath.row]

        let basicCell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "cell",
            for: indexPath
        )

        switch model {

        case .banner(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExploreBannerCollectionViewCell.identifier,
                for: indexPath
            ) as? ExploreBannerCollectionViewCell else {
                return basicCell
            }

            cell.configure(with: viewModel)
            return cell
        case .post(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExplorePostCollectionViewCell.identifier,
                for: indexPath
            ) as? ExplorePostCollectionViewCell else {
                return basicCell
            }

            cell.configure(with: viewModel)
            return cell
        case .hashtag(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExploreHashtagCollectionViewCell.identifier,
                for: indexPath
            ) as? ExploreHashtagCollectionViewCell else {
                return basicCell
            }

            cell.configure(with: viewModel)
            return cell
        case .user(let viewModel):
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ExploreUserCollectionViewCell.identifier,
                for: indexPath
            ) as? ExploreUserCollectionViewCell else {
                return basicCell
            }

            cell.configure(with: viewModel)
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSeletion()

        let model: ExploreCell = sections[indexPath.section].cells[indexPath.row]

        switch model {
        case .banner(let viewModel):
            break
        case .post(let viewModel):
            break
        case .hashtag(let viewModel):
            break
        case .user(let viewModel):
            break
        }
    }

}

// MARK: - ExploreViewController section layouts

extension ExploreViewController {

    func layout(for section: Int) -> NSCollectionLayoutSection {
        let sectionType = sections[section].type

        switch sectionType {

        case .banners:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(0.9),
                    heightDimension: .absolute(200)
                ),
                subitems: [item]
            )

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .groupPaging

            return sectionLayout
        case .users:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(150),
                    heightDimension: .absolute(200)
                ),
                subitems: [item]
            )

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .continuous

            return sectionLayout
        case .trendingHashtags:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .absolute(60)
                ),
                subitems: [item]
            )

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: verticalGroup)

            return sectionLayout
        case .popular:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(110),
                    heightDimension: .absolute(200)
                ),
                subitems: [item])

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .continuous

            return sectionLayout
        case .new, .trendingPosts, .recommended:
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )

            item.contentInsets = NSDirectionalEdgeInsets(
                top: 4,
                leading: 4,
                bottom: 4,
                trailing: 4
            )

            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(100),
                    heightDimension: .absolute(300)
                ),
                subitem: item,
                count: 2
            )

            let group = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .absolute(110),
                    heightDimension: .absolute(300)
                ),
                subitems: [verticalGroup])

            // Horizontal scrolling section layout
            let sectionLayout = NSCollectionLayoutSection(group: group)
            sectionLayout.orthogonalScrollingBehavior = .continuous

            return sectionLayout
        }
    }
}
