# Voting System Changes - Vote Value Standardization

## Summary
Updated the voting system to use standardized vote values across all voting screens:
- **YES votes now send: 1**
- **NO votes now send: 2**

## Files Modified

### 1. `/lib/shareholder_vote_page.dart`
**Changes in `_normalVoteButtons()` method:**
- YES button: Changed vote value from `"3"` to `"1"`
- NO button: Vote value remains `"2"`
- Vote status check: Updated to check for `resExistingVote == "1"` for YES votes

### 2. `/lib/ProxyNormalVote.dart`
**Changes in `_shareholderTile()` method:**
- YES button: Changed vote value from `"3"` to `"1"`
- NO button: Vote value remains `"2"`
- Vote status check: Updated to check for `existingVote == "1"` for YES votes
- Vote label: Changed from "Abstain" to "For" when vote is "1"
- `hasVoted` check: Updated to include `existingVote == "1"`

**Changes in bulk vote buttons:**
- YES ALL button: Changed vote value from `"3"` to `"1"`
- NO ALL button: Vote value remains `"2"`
- Vote status check: Updated to check for `vote == "1"` for YES ALL

## API Integration
All changes are backward compatible with the backend API. The API endpoints will now receive:
- `1` for YES votes
- `2` for NO votes

Example API calls:
```
handleNormalVote(cdsNumber, resNumber, "1")  // YES vote
handleNormalVote(cdsNumber, resNumber, "2")  // NO vote
handleNormalVoteAll(resolutionSEQ, proxyNumber, "1")  // YES ALL votes
handleNormalVoteAll(resolutionSEQ, proxyNumber, "2")  // NO ALL votes
```

## Testing Recommendations
1. Test shareholder normal resolution voting (YES/NO)
2. Test proxy normal resolution voting (individual and bulk YES/NO)
3. Verify vote status displays correctly after voting
4. Confirm vote values are sent correctly to the backend API

## Vote Type Matrix
| Resolution Type | Vote Action | Vote Value |
|---|---|---|
| Normal Resolution | YES | 1 |
| Normal Resolution | NO | 2 |
| Election | YES (Vote for candidate) | 1 |
| Election | RECAST | 3 |

## Notes
- Election votes (proxy and shareholder) were already using value `1` for YES, so no changes were needed there
- The vote value `3` previously used for "Abstain" is being replaced with `1` for consistency
- All vote status displays throughout the UI have been updated to reflect the new vote values

