From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 0/6] phylib: cleanups
Date: Sat, 04 Jan 2014 19:39:47 -0500 (EST)
Message-ID: <20140104.193947.2145307655427550677.davem@davemloft.net>
References: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44512 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754955AbaAEAjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 19:39:51 -0500
In-Reply-To: <201401050315.29587.sergei.shtylyov@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 5 Jan 2014 03:15:29 +0300

>    This patchset mainly cleans up the phylib's coding style but then also
> removes some historically unused stuff. It's kind of follow up to the recent
> Florian Fainelli's series which didn't finish checkpatch.pl complaint fixing.
> The patchset is against DaveM's 'net-next.git' repo.
> 
> [1/8] phy: coding style fixes
> [2/8] mdio_bus: coding style fixes
> [3/8] <linux/phy.h>: coding style fixes
> [4/8] phy: kill useless local variables
> [5/8] phy: kill excess code
> [6/8] phy: kill excess empty lines
> [7/8] phylib: remove unused adjust_state() callback
> [8/8] phylib: make phy_scan_fixups() static

Series applied, thanks.
