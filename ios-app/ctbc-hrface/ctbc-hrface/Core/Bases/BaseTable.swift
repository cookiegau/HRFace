import Foundation
import UIKit

class BaseTable: UITableView {
    
    var numberOfRowsInSection:((_ section: Int) -> Int)?
    
    var cellForRowAtIndexPath:((_ tableView: UITableView,_ indexPath: IndexPath) -> UITableViewCell)?
    
    var numberOfSectionsInTableView:((_ tableView: UITableView) -> Int)?
    
    var titleForHeaderInSection:((_ tableView:UITableView, _ section:Int) -> String?)?
    
    var titleForFooterInSection:((_ tableView:UITableView, _ section:Int) -> String?)?
    
    var canEditRowAt:((_ tableView: UITableView, _ canEditRowAtIndexPath: IndexPath) -> Bool )?
    
    var canMoveRowAt:((_ tableView: UITableView, _ canMoveRowAtIndexPath: IndexPath) -> Bool )?
    
    var sectionIndexTitles:((_ tableView: UITableView) -> [String]?)?
    
    var sectionForSectionIndexTitle:((_ tableView: UITableView, _ sectionForSectionIndexTitle: String, _ atIndex: Int) -> Int )?
    
    var commit:((_ tableView:UITableView, _ editingStyle: UITableViewCell.EditingStyle, _ forRowAtIndexPath: IndexPath) -> Void )?
    
    var moveRowAt:((_ tableView: UITableView, _ moveRowAtSourceIndexPath: IndexPath, _ toDestinationIndexPath: IndexPath) -> Void )?
    
    var willDisplayCell:((_ tableView: UITableView,_ cell:UITableViewCell, _ indexPath: IndexPath) -> Void)?
    
    var heightForRowAtIndexPath:((_ tableView: UITableView, _ indexPath: IndexPath) -> CGFloat)?
    
    var didSelectRowAtIndexPath:((_ tableView: UITableView, _ indexPath: IndexPath) -> Void)?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
	
	init( _ frame: CGRect, _ style: UITableView.Style = .plain )
	{
		super.init( frame: frame, style: style )
		self.setup()
	}
    
    private func setup() {
        self.delegate = self
        self.dataSource = self
    }
	
	func RegisterBy( nibName: String, reuseId: String? = nil )
	{
		var ruseIdentifier = nibName
		if reuseId != nil { ruseIdentifier = nibName }
		self.register( UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: ruseIdentifier )
	}
}

extension BaseTable : UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let callback = self.numberOfRowsInSection { return callback(section) }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let callback = self.cellForRowAtIndexPath { return callback(tableView, indexPath) }
        return UITableViewCell()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let callback = self.numberOfSectionsInTableView { return callback(tableView) }
        return 0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let callback = self.titleForHeaderInSection { return callback(tableView, section) }
        return nil
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if let callback = self.titleForFooterInSection { return callback(tableView, section) }
        return nil
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let callback = self.canEditRowAt { return callback(tableView, indexPath) }
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let callback = self.canMoveRowAt { return callback(tableView, indexPath) }
        return false
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let callback = self.sectionIndexTitles { return callback(tableView) }
        return nil
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let callback = self.sectionForSectionIndexTitle { return callback(tableView, title, index) }
        return 0
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let callback = self.commit { return callback(tableView, editingStyle, indexPath) }
        return
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let callback = self.moveRowAt { return callback(tableView, sourceIndexPath, destinationIndexPath) }
        return
    }
}

extension BaseTable : UITableViewDelegate
{
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
	{
        if let callback = self.willDisplayCell { return callback(tableView, cell, indexPath) }
    }
	
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
	{
        if let callback = self.heightForRowAtIndexPath { return callback(tableView, indexPath) }
        return self.estimatedRowHeight
    }
	
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
	{
        if let callback = self.didSelectRowAtIndexPath { return callback(tableView, indexPath) }
    }
}

extension UITableView
{
    func isLastVisibleCell( at indexPath: IndexPath ) -> Bool
	{
        guard let lastIndexPath = indexPathsForVisibleRows?.last else { return false }
        return lastIndexPath == indexPath
    }
}
