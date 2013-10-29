From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/arc/arc_emac: drop redundant mac address check
Date: Mon, 28 Oct 2013 23:48:42 -0400 (EDT)
Message-ID: <20131028.234842.1406231268962965513.davem@davemloft.net>
References: <1383010340-26445-1-git-send-email-luka@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, abrodkin@synopsys.com
To: luka@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40208 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752001Ab3J2Dsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 23:48:47 -0400
In-Reply-To: <1383010340-26445-1-git-send-email-luka@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I've seen you use three inconsistent Subject prefixes here, pick a scheme
and stick to it please!

First patch was:

netdev: ${driver_name}:

Second patch was:

net: ${driver_name}:

Third patch was:

patch/to/driver/directory:

This is really not acceptable.  Just using "${driver_name}: " is good
enough.
