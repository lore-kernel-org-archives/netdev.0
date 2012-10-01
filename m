From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gre: fix sparse warning
Date: Mon, 01 Oct 2012 17:36:02 -0400 (EDT)
Message-ID: <20121001.173602.1156275994432305144.davem@davemloft.net>
References: <20120929011210.GA10053@localhost>
	<20121001082114.0803f6d1@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fengguang.wu@intel.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41402 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752152Ab2JAVgE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 17:36:04 -0400
In-Reply-To: <20121001082114.0803f6d1@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 1 Oct 2012 08:21:14 -0700

> Use be16 consistently when looking at flags.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
