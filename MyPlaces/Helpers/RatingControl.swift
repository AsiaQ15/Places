//
//  RatingControl.swift
//  MyPlaces
//
//  Created by Ася Купинская on 08.10.2022.
//

import UIKit

@IBDesignable  class RatingControl: UIStackView {
    
    //MARK: properties
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
    private var ratingButtons =  [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 44.0, height: 44.0) {
        didSet{
            setupButtons()
        }
    }
    @IBInspectable var starCount: Int = 5 {
        didSet{
            setupButtons()
        }
    }

    //MARK: Initialization
    //через фрейм задание
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButtons()
    }
    //через код
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    //MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton){
        //индекс кнопки к которой касается пользователь
        guard let index = ratingButtons.firstIndex(of: button) else {return}
        //Calculete the rating of the  selected button
        let selectedRating = index + 1
        //если выбрали звезду текущего рейтинга то обнуляем
        if selectedRating == rating{
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    //MARK: Private methods
    private func setupButtons(){
        
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview()
            
        }
        
        ratingButtons.removeAll()
        
        //Load button image
        let bundel =  Bundle(for: type(of: self)) //определяем положение ресурсов в каталоге
        let filledStar = UIImage(named: "filledStar", in: bundel, compatibleWith: self.traitCollection)
        let emptyStar = UIImage(named: "emptyStar", in: bundel, compatibleWith: self.traitCollection)
        let highlightedStar = UIImage(named: "highlightedStar", in: bundel, compatibleWith: self.traitCollection)
        
        for _ in 0..<starCount {
                
            //create the button
            let button = UIButton()
            
            //set the button image
            button.setImage(emptyStar, for: .normal) //обычное сотояние
            button.setImage(filledStar, for: .selected) //выделенное состяние (определяется программно)
            button.setImage(highlightedStar, for: .highlighted) //прикосновение
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
            
            //Add constraints
            //отключение автоматически сгенерированых констрейнов
            button.translatesAutoresizingMaskIntoConstraints = false
            //высота кнопки
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true
            //ширина кнопки
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
            //Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
            //Add button to stack
            addArrangedSubview(button)
            
            //Add new button on o the rating array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
    }
    
    //установка вида звезд
    private func updateButtonSelectionState(){
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
