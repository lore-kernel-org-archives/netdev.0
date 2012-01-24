From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: [PATCH iproute2 0/2] netem: Fixes to man page
Date: Mon, 23 Jan 2012 22:08:50 -0800
Message-ID: <1327385332-20776-1-git-send-email-subramanian.vijay@gmail.com>
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Vijay Subramanian <subramanian.vijay@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:46284 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885Ab2AXGJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2012 01:09:45 -0500
Received: by iacb35 with SMTP id b35so4878275iac.19
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2012 22:09:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These patches fix the netem man page. There were some errors not caught by spell
check and the text on reordering was incorrect. Please consider applying.

Thanks,


Vijay Subramanian (2):
  netem: Fix up grammatical errors in man page
  netem: Fix 'reorder' section of man page

 man/man8/tc-netem.8 |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)
