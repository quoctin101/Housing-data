/*
Cleaning Data in SQL Queries
*/

Use SQL_Portfolio_Project

Select *
From SQL_Portfolio_Project.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate)   -- this is to remove 00:00:00 at the end of date time
From SQL_Portfolio_Project.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
add SaleDateConverted Date;


update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

Select SaleDateConverted   
From SQL_Portfolio_Project.dbo.NashvilleHousing
-- If it doesn't Update properly




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data (there is some missing address, now join table with itself to get filling in the missing address)


Select *   
From SQL_Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


-- Join table with itself then use it to update the missing vavlue in property address. Also made sure the unqueID are difference so null wont connect to null.
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,ISNULL(a.PropertyAddress, b.PropertyAddress)   --is null to help replace property address with b.property address when a.property address is null
From SQL_Portfolio_Project.dbo.NashvilleHousing a
Join SQL_Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null


--UPDATE table in order to get rip of the null.
Update a -- can not use the actual table to update
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)   
From SQL_Portfolio_Project.dbo.NashvilleHousing a
Join SQL_Portfolio_Project.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is Null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress   
From SQL_Portfolio_Project.dbo.NashvilleHousing


Select PropertyAddress
From SQL_Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

--Substring to break down the string then select from what position to what position in that STRING we want to select.
-- Charindex is to select from what is the length from specific 'charactor that we want to take) 

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address, 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as City
From SQL_Portfolio_Project.dbo.NashvilleHousing



--Alter Table first to add 
Alter Table SQL_Portfolio_Project.dbo.NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update SQL_Portfolio_Project.dbo.NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


Alter Table SQL_Portfolio_Project.dbo.NashvilleHousing
add PropertySplitCity NvarChar(255);

update SQL_Portfolio_Project.dbo.NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress))




Select PropertySplitAddress,PropertySplitCity
From SQL_Portfolio_Project.dbo.NashvilleHousing


--Now we are looking at the OwnerAddress

Select OwnerAddress
From SQL_Portfolio_Project.dbo.NashvilleHousing

-- We can use Substring again but i take long so we can use ParseName() function to accomplish the same thing// 
-- however PARSENAME() only work on period so we need to convert comma into period with REPLACE() function then apply Parsename()

Select
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From SQL_Portfolio_Project.dbo.NashvilleHousing

-- now add column into table to reflect owner address

Alter Table SQL_Portfolio_Project.dbo.NashvilleHousing
add OwnerSplitAddress Nvarchar(255);

update SQL_Portfolio_Project.dbo.NashvilleHousing
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)


Alter Table SQL_Portfolio_Project.dbo.NashvilleHousing
add OwnerSplitCity Nvarchar(255);

update SQL_Portfolio_Project.dbo.NashvilleHousing
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

Alter Table SQL_Portfolio_Project.dbo.NashvilleHousing
add OwnerSplitState Nvarchar(255);

update SQL_Portfolio_Project.dbo.NashvilleHousing
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
From SQL_Portfolio_Project.dbo.NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------




-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant),count(SoldAsVacant)
From SQL_Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

-- Use case statement to break down case to change 'Y' to 'Yes' and 'N' to "No"
select SoldAsVacant
, case when SoldAsVacant = 'Y' Then 'Yes'
	   when SoldAsVacant = 'N' Then 'No'
       else SoldAsVacant
	   End 
From SQL_Portfolio_Project.dbo.NashvilleHousing

-- Now updated table
Update SQL_Portfolio_Project.dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
					    when SoldAsVacant = 'N' Then 'No'
					    else SoldAsVacant
					    End 

-- Now check
Select Distinct(SoldAsVacant),count(SoldAsVacant)
From SQL_Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
-- USE CTE// With will help create CTE
-- delete Dubplication first, then select it.


With Row_numCTE as(
select * ,
		ROW_NUMBER()OVER(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by
					 UniqueID
					 )Row_num
From SQL_Portfolio_Project.dbo.NashvilleHousing
--Order by ParcelID
)
Delete
From Row_numCTE
Where Row_num >1
-- Order by PropertyAddress

With Row_numCTE as(
select * ,
		ROW_NUMBER()OVER(
		Partition by ParcelID,
					 PropertyAddress,
					 SalePrice,
					 SaleDate,
					 LegalReference
					 Order by
					 UniqueID
					 )Row_num
From SQL_Portfolio_Project.dbo.NashvilleHousing
--Order by ParcelID
)
Select*
From Row_numCTE
--Where Row_num >1
Order by PropertyAddress


-- Delete all the duplicate
Delete
From Row_numCTE
Where Row_num >1


Select *
From Row_numCTE
--Where Row_num >1
Order by PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select * 
From SQL_Portfolio_Project.dbo.NashvilleHousing;


Alter table SQL_Portfolio_Project.dbo.NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


