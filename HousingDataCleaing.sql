Select *
From PortfolioProject..NashvilleHousing

-- Change SaleDate datatype

Select SaleDate, CONVERT(Date,SaleDate)
From PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
ALTER COLUMN SaleDate Date

-- Populate Property Address Data

Select *
From PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null



Update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


-- Breaking out addresses into Individual Columns 

--Property Address
Select PropertyAddress
From PortfolioProject..NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress)-1) as address
, SUBSTRING(PropertyAddress, CharIndex(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
From PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CharIndex(',', PropertyAddress)+1, LEN(PropertyAddress))

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CharIndex(',', PropertyAddress)-1)


-- Owner Address

Select OwnerAddress 
From PortfolioProject..NashvilleHousing

Select 
PARSENAME(Replace(OwnerAddress,',','.'), 3)
,PARSENAME(Replace(OwnerAddress,',','.'),2)
,PARSENAME(Replace(OwnerAddress,',','.'), 1)
From PortfolioProject..NashvilleHousing



ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update PortfolioProject..NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'), 1)


-- Change Y and N to Yes and No

Select Distinct(SoldAsVacant)
, Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject..NashvilleHousing

Update PortfolioProject..NashvilleHousing
Set SoldAsVacant = 
Case when SoldAsVacant = 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' Then 'No'
		ELSE SoldAsVacant
		END


--Remove Duplicates



WITH RowNumCTE AS(
Select *,
ROW_NUMBER() Over (
Partition By ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference 
ORDER BY UniqueID)
row_num
From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
where row_num > 1
--Order by PropertyAddress

-- Delete unused columns

Select *
From PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress




