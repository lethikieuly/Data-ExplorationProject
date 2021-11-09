/* 

CLEAN DATA BY SQL 

*/

-------------------------------------------------------------------------------

--Explore data
SELECT * 
FROM Project..Housing
--1/ Standardize Date Format
SELECT SaleDate, CONVERT(date,SaleDate)
FROM Project..Housing

UPDATE Housing
SET SaleDate =  CONVERT(date,SaleDate)
--But it some issues. My main table housing not update. Why not it was doing 

ALTER TABLE Housing
ADD SaleDateConverted date;

UPDATE Housing 
SET SaleDateConverted= CONVERT(date, SaleDate)

SELECT SaleDateConverted, CONVERT(date,SaleDate)
FROM Project..Housing
-------------------------------------------------------------------------------

-- Populate Property Address Data
SELECT PropertyAddress
FROM Project..Housing
--WHERE PropertyAddress is null, I try it but Many information is useful, So I can delete
ORDER BY  ParcelID
--When parcelID the same, Property Address similar


SELECT a.[UniqueID ],b.[UniqueID ], a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Project..Housing a
JOIN Project..Housing b
ON a.ParcelID=b.ParcelID
AND a.[UniqueID]<>b.[UniqueID]
WHERE a.PropertyAddress is null

-------------------------------------------------------------------------------
-- Breaking out Address into invidual Column (address, city, state)
 
 SELECT *
 FROM Project..Housing
 -- 617 A  EASTBORO DR, NASHVILLE. My task is split it into (address: 617 A  EASTBORO DR, City: NASHVILLE)
 SELECT SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS a --Address,
 SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS b--City
 FROM Project..Housing
 
 ALTER TABLE Housing
 ADD PropertySplitAddress NVARCHAR(255)

 UPDATE Housing 
 SET PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

 ALTER TABLE Housing 
 ADD preopertySplitCity NVARCHAR(255)

 UPDATE Housing
 SET preopertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

 --Owner Address, ex: 5905  MACKIE ST. NASHVILLE, TN
 SELECT OwnerAddress
 FROM Project..Housing

 SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),--ADDRESS
PARSENAME(REPLACE(OwnerAddress,',','.'),2),--CITY
PARSENAME(REPLACE(OwnerAddress,',','.'),1)--STATE
FROM Project..Housing

ALTER TABLE Housing 
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE Housing
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Housing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE Housing
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)--CITY

ALTER TABLE Housing
ADD OwnerSplitState NVARCHAR(255)

UPDATE Housing
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT * 
FROM Project..Housing


-------------------------------------------------------------------------------

--Chang Y and N to Yes and No in "Sold as Vacant" field
 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM Project..Housing
GROUP BY SoldAsVacant
ORDER BY 2
-- In here, 'N','Yes','Y','No'
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
FROM Project..Housing
 
UPDATE Housing
SET SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
	 END
-------------------------------------------------------------------------------
--I have problem 
--Remove dublicates
/* SELECT * 
FROM Project..Housing

WITH RowNumCTE AS
(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM Project..Housing
)
--order by ParcelID

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing*/














































































































































































































































































































































































































































































































































































































































































































































