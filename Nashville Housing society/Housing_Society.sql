select * from PortfolioProject.dbo.Housing

--standardized date format
select saleDateConverted , CONVERT(date, SaleDate)
from PortfolioProject.dbo.Housing

update PortfolioProject..Housing
SET SaleDate = CONVERT(Date, SaleDate)

alter table PortfolioProject..Housing
add saleDateConverted Date

update PortfolioProject..Housing
SET saleDateConverted = CONVERT(Date, SaleDate)

--populate property address data
select * from PortfolioProject.dbo.Housing
where PropertyAddress is null
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..Housing a
join PortfolioProject..Housing b
 on a.ParcelID = b.ParcelID
    and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..Housing a
join PortfolioProject..Housing b
 on a.ParcelID = b.ParcelID
    and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


--breaking out address into individual coloumns(city,state,address)
select 
substring (PropertyAddress, 1, CHARINDEX(',',PropertyAddress -1)) as address,
substring (PropertyAddress, CHARINDEX(',',PropertyAddress) +1 , len(PropertyAddress)) as address
from PortfolioProject..Housing 

Alter table Housing
add PropertySplitAddress Nvarchar(255)

update Housing
set PropertySplitAddress = substring(PropertyAddress, 1, charindex(',' ,PropertyAddress )-1)

alter table Housing
add PropertySplitAddress Nvarchar(255)

update Housing
set PropertySplitCity = substring(PropertyAddress, charindex(',' ,PropertyAddress )+1, len(PropertyAddress))

select OwnerAddress
from PortfolioProject..Housing


--owner address
select  
parsename(replace(OwnerAddress,',' , '.') ,3),
parsename(replace(OwnerAddress,',' , '.') ,2),
parsename(replace(OwnerAddress,',' , '.') ,1)
from PortfolioProject..Housing


Alter table PortfolioProject..Housing
add OwnerSplitAddress Nvarchar(255)

update PortfolioProject..Housing
set OwnerSplitAddress =parsename(replace(OwnerAddress,',' , '.') ,3)

alter table PortfolioProject..Housing
add OwnerSplitCity Nvarchar(255)

update PortfolioProject..Housing
set OwnerSplitCity = parsename(replace(OwnerAddress,',' , '.') ,2)

alter table PortfolioProject..Housing
add OwnerSplitState Nvarchar(255)

update PortfolioProject..Housing
set OwnerSplitState = parsename(replace(OwnerAddress,',' , '.') ,1)

select * from PortfolioProject..Housing

--change Y and N in sold as vacant col
select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..Housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
     else SoldAsVacant
     End
--from PortfolioProject..Housing

update PortfolioProject..Housing
set SoldAsVacant = case when SoldAsVacant = 'Y' Then 'Yes'
     when SoldAsVacant = 'N' Then 'No'
     else SoldAsVacant
     End

--remove duplicates

with RowNumCTE as (
select *,
ROW_NUMBER() over (partition by ParcelID, PropertyAddress, SalePrice, SaleDate, Legalreference
order by UniqueID) row_num 
from PortfolioProject..Housing)
select *  from RowNumCTE
where row_num > 1
order by PropertyAddress

--delete  from RowNumCTE
--where row_num > 1
----order by PropertyAddress

--delete unused columns
Alter table PortfolioProject..Housing
drop column OwnerAddress, TaxDistrict

select *  from PortfolioProject..Housing
