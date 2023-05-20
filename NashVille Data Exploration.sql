/*
Nashville Housing Data Cleaning Project

Skills used: CTE, Window Functions, Joins, Aggregate Functions, Creating Views, Converting Data Types

*/
SELECT *
FROM [Nashville Housing Data] 

-- Populate Property Address Data

SELECT A.ParcelID,
       A.PropertyAddress,
       B.ParcelID,
       B.PropertyAddress,
       ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [Nashville Housing Data] A
JOIN [Nashville Housing Data] B ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL
  UPDATE A
  SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
  SELECT A.ParcelID,
         A.PropertyAddress,
         B.ParcelID,
         B.PropertyAddress,
         ISNULL(A.PropertyAddress, B.PropertyAddress)
  FROM [Nashville Housing Data] A
  JOIN [Nashville Housing Data] B ON A.ParcelID = B.ParcelID
  AND A.UniqueID <> B.UniqueID WHERE A.PropertyAddress IS NULL 
  
  -- Breaking out address into individual columns

  SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address1,
         SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address2
  FROM [Nashville Housing Data] 
  
  -- Creating new columns and adding splitted columns to the dataset

  ALTER TABLE [Nashville Housing Data] ADD PropertyAddressSplit NVARCHAR(255)
  UPDATE [Nashville Housing Data]
  SET PropertyAddressSplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)
  ALTER TABLE [Nashville Housing Data] ADD PropertyCitySplit NVARCHAR(255)
  UPDATE [Nashville Housing Data]
  SET PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) -- Similar to the PropertyAddress column, we will split up the OwnerAddress into (Address, City and State) respectively

  SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
         PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
         PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
  FROM [Nashville Housing Data] 
  
  -- Creating new columns and adding splitted columns to the dataset

  ALTER TABLE [Nashville Housing Data] ADD OwnerAddressSplit NVARCHAR(255)
  UPDATE [Nashville Housing Data]
  SET PropertyCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
  ALTER TABLE [Nashville Housing Data] ADD OwnerCitySplit NVARCHAR(255)
  UPDATE [Nashville Housing Data]
  SET PropertyCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
  ALTER TABLE [Nashville Housing Data] ADD OwnerStateSplit NVARCHAR(255)
  UPDATE [Nashville Housing Data]
  SET PropertyCitySplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
  
  -- Change 0 to No and 1 to Yes in SoldAsVacant field

  ALTER TABLE [Nashville Housing Data]
  ALTER COLUMN SoldAsVacant VARCHAR(5)
  SELECT SoldAsVacant,
         CASE
             WHEN (SoldAsVacant) = '1' THEN 'Yes'
             WHEN (SoldAsVacant) = '0' THEN 'No'
             ELSE SoldAsVacant
         END
  FROM [Nashville Housing Data]
  UPDATE [Nashville Housing Data]
  SET SoldAsVacant = CASE
                         WHEN (SoldAsVacant) = '1' THEN 'Yes'
                         WHEN (SoldAsVacant) = '0' THEN 'No'
                         ELSE SoldAsVacant
                     END 
					 
-- Removing Duplicate Records

 WITH RowNumber_CTE AS
    (SELECT *,
            ROW_NUMBER() OVER (PARTITION BY ParcelID,
                                            PropertyAddress,
                                            SalePrice,
                                            SaleDate,
                                            LegalReference
                               ORDER BY UniqueID) AS Row_Num
     FROM [Nashville Housing Data] 
	 -- ORDER BY ParcelID
)
  DELETE
  FROM RowNumber_CTE WHERE Row_Num > 1 
  -- ORDER BY PropertyAddress

-- Deleting Unused/Unwanted Columns (OwnerAddress, TaxDistrict and PropertyAddress)
-- Disclaimer: Deleting records from a database is not best practice hence, this is not adviced

  ALTER TABLE [Nashville Housing Data]
  DROP COLUMN OwnerAddress,
              TaxDistrict,
              PropertyAddress