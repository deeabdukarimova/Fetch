-- Query on QUESTION 1 
SELECT
  b.name AS brand_name,
  COUNT(*) AS receipts_scanned
FROM
  brands b
  INNER JOIN receipts r ON b.cpg_id = JSON_VALUE(r.rewardsReceiptItemList, '$[*].rewardsProductPartnerId')
WHERE
  date_format(FROM_UNIXTIME(r.dateScanned / 1000), '%Y-%m') = (
    SELECT MAX(date_format(FROM_UNIXTIME(receipts.dateScanned / 1000), '%Y-%m'))
    FROM receipts
  )
GROUP BY
  b.name
ORDER BY
  receipts_scanned DESC
LIMIT 5;

-- Query on QUESTION 2
SELECT
  recent.brand_name AS recent_month_brand_name,
  recent.receipts_scanned AS recent_month_receipts_scanned,
  previous.brand_name AS previous_month_brand_name,
  previous.receipts_scanned AS previous_month_receipts_scanned
FROM
  (
    SELECT
      b.name AS brand_name,
      COUNT(*) AS receipts_scanned
    FROM
      brands b
      INNER JOIN receipts r ON b.cpg_id = JSON_VALUE(r.rewardsReceiptItemList, '$[*].rewardsProductPartnerId')
    WHERE
      date_format(FROM_UNIXTIME(r.dateScanned / 1000), '%Y-%m') = (
        SELECT MAX(date_format(FROM_UNIXTIME(receipts.dateScanned / 1000), '%Y-%m'))
        FROM receipts
      )
    GROUP BY
      b.name
    ORDER BY
      receipts_scanned DESC
    LIMIT 5
  ) AS recent
  CROSS JOIN (
    SELECT
      b.name AS brand_name,
      COUNT(*) AS receipts_scanned
    FROM
      brands b
      INNER JOIN receipts r ON b.cpg_id = JSON_VALUE(r.rewardsReceiptItemList, '$[*].rewardsProductPartnerId')
    WHERE
      date_format(FROM_UNIXTIME(r.dateScanned / 1000), '%Y-%m') = (
        SELECT DATE_FORMAT(DATE_SUB(MAX(FROM_UNIXTIME(receipts.dateScanned / 1000)), INTERVAL 3 MONTH), '%Y-%m')
        FROM receipts
      )
    GROUP BY
      b.name
    ORDER BY
      receipts_scanned DESC
    LIMIT 5
  ) AS previous;

-- Query on QUESTION 3
SELECT
  ROUND((SELECT AVG(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'REJECTED'), 2) AS avgSpentRejectedRewardsReceiptStatus,
  ROUND((SELECT AVG(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'FINISHED'), 2) AS avgSpentAcceptedRewardsReceiptStatus,
  CASE
    WHEN (SELECT AVG(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'REJECTED') > (SELECT AVG(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'FINISHED') THEN 'avgSpentRejectedRewardsReceiptStatus is higher'
    WHEN (SELECT AVG(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'REJECTED') < (SELECT AVG(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'FINISHED') THEN 'avgSpentAcceptedRewardsReceiptStatus is higher'
  END AS result;

-- Query on QUESTION 4
SELECT
  ROUND((SELECT SUM(purchasedItemCount) FROM receipts WHERE rewardsReceiptStatus = 'REJECTED'), 2) AS sumItemsPurchasedRejectedRewardsReceiptStatus,
  ROUND((SELECT SUM(purchasedItemCount) FROM receipts WHERE rewardsReceiptStatus = 'FINISHED'), 2) AS sumItemsPurchasedAcceptedRewardsReceiptStatus,
  CASE
    WHEN (SELECT SUM(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'REJECTED') > (SELECT SUM(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'FINISHED') THEN 'sumItemsPurchasedRejectedRewardsReceiptStatus is higher'
    WHEN (SELECT SUM(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'REJECTED') < (SELECT SUM(totalSpent) FROM receipts WHERE rewardsReceiptStatus = 'FINISHED') THEN 'sumItemsPurchasedAcceptedRewardsReceiptStatus is higher'
  END AS result;

-- Query on QUESTION 5
SELECT
  b.name AS brand_name,
  SUM(JSON_VALUE(r.rewardsReceiptItemList, '$[*].finalPrice')) AS finalPrice
FROM
  brands b
  INNER JOIN receipts r ON b.cpg_id = JSON_VALUE(r.rewardsReceiptItemList, '$[*].rewardsProductPartnerId')
  INNER JOIN users u ON r.userId = u._id
WHERE
  FROM_UNIXTIME(u.createdDate / 1000) >= (
    SELECT DATE_SUB(MAX(FROM_UNIXTIME(createdDate / 1000)), INTERVAL 6 MONTH)
    FROM users
  )
GROUP BY
  b.name
ORDER BY
  finalPrice DESC
LIMIT 1;

-- Query on QUESTION 6
SELECT
  b.name AS brand_name,
  COUNT(*) AS transaction_count
FROM
  brands b
  INNER JOIN receipts r ON b.cpg_id = JSON_VALUE(r.rewardsReceiptItemList, '$[*].rewardsProductPartnerId')
  INNER JOIN users u ON r.userId = u._id
WHERE
  FROM_UNIXTIME(u.createdDate / 1000) >= (
    SELECT DATE_SUB(MAX(FROM_UNIXTIME(createdDate / 1000)), INTERVAL 6 MONTH)
    FROM users
  )
GROUP BY
  b.name
ORDER BY
  transaction_count DESC
LIMIT 1;
