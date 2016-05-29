From: Kirtika Ruchandani <kirtika.ruchandani@gmail.com>
Subject: [PATCH 0/3] nl80211: Fix checkpatch.pl issues
Date: Sat, 28 May 2016 20:30:21 -0700
Message-ID: <cover.1464492195.git.kirtika.ruchandani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, ruchandani.tina@gmail.com,
	netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:33297 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcE2Dae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 May 2016 23:30:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set attempts to fix checkpatch.pl issues found in nl80211.c. 
Each patch describes the specific warnings/checks/errors it addresses. 
This patch-set ignores 'line over 80 chars' warnings.
Please check for issues with the 'fixes' for 'alignment should match 
open parenthesis'. Some of them do not display correctly with git diff.
This patch-set removes 3 errors, 66 warnings and 46 checks. 

Kirtika Ruchandani (3):
  nl80211: Fix checkpatch warnings
  nl80211: Fix checkpatch warnings about blank lines
  nl80211:  Various checkpatch.pl fixes

 net/wireless/nl80211.c | 303 ++++++++++++++++++++++---------------------------
 1 file changed, 137 insertions(+), 166 deletions(-)

-- 
2.8.0.rc3.226.g39d4020
