\copy item_categories
from '/Users/cameron/Dev/pos-data-generator/scripts/mockaroo/datasets/item_categories.csv'
DELIMITER ','
CSV Header;

\copy item_master 
from '/Users/cameron/Dev/pos-data-generator/scripts/mockaroo/datasets/item_master.csv'
DELIMITER ','
CSV Header;

\copy retail_stores 
from '/Users/cameron/Dev/pos-data-generator/scripts/mockaroo/datasets/retail_stores.csv'
DELIMITER ','
CSV Header;