From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 15/15] netdev: relocate LICENSE.SRC to legacy
Date: Thu, 28 Oct 2010 21:19:19 -0400
Message-ID: <1288315159-1350-16-git-send-email-paul.gortmaker@windriver.com>
References: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:34007 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759686Ab0J2BTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 21:19:36 -0400
In-Reply-To: <1288315159-1350-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A grep for "..GNU General Public License as modified by SRC.." shows
that this license file only applies to some of the earliest
drivers added ~15 years ago.  Since all these drivers are now in the
legacy dir, the license might as well be too.

Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/net/{ => legacy}/LICENSE.SRC |    0
 1 files changed, 0 insertions(+), 0 deletions(-)
 rename drivers/net/{ => legacy}/LICENSE.SRC (100%)

diff --git a/drivers/net/LICENSE.SRC b/drivers/net/legacy/LICENSE.SRC
similarity index 100%
rename from drivers/net/LICENSE.SRC
rename to drivers/net/legacy/LICENSE.SRC
-- 
1.7.3.2.146.g2d444

