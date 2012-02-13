From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 0/8] tg3: Eliminate function prototypes
Date: Mon, 13 Feb 2012 12:20:04 -0800
Message-ID: <1329164412-24566-1-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com, mchan@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3687 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757969Ab2BMUVB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Feb 2012 15:21:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this patchset is to eliminate most function
prototypes in the tg3 sources.
