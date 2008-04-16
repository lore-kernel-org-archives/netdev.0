From: Allan Stephens <allan.stephens@windriver.com>
Subject: [PATCH 0/3 net-2.6.26] [TIPC]: Reference table enhancements <REVISED>
Date: Wed, 16 Apr 2008 14:27:23 -0400
Message-ID: <1208370446-12065-1-git-send-email-allan.stephens@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51868 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750859AbYDPS30 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Apr 2008 14:29:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch set contains 3 sets of enhancements to TIPC's object
reference table. Please see each individual patch for further description.

Summary:

 net/tipc/ref.c |  211 +++++++++++++++++++++++++++++++++++++++++---------------
 net/tipc/ref.h |   89 +-----------------------
 2 files changed, 159 insertions(+), 141 deletions(-)

Allan Stephens (3):
      [TIPC]: Remove inlining of reference table locking routines
      [TIPC]: Optimized initialization of TIPC reference table
      [TIPC]: Cleanup of TIPC reference table code

Thanks,
Al
