From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/5] Don't return NULL from get_phy_device() anymore
Date: Tue, 26 Apr 2016 15:41:36 -0400 (EDT)
Message-ID: <20160426.154136.2199967647306589290.davem@davemloft.net>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org, arnd@arndb.de
To: sergei.shtylyov@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41513 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbcDZTli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 15:41:38 -0400
In-Reply-To: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Sun, 24 Apr 2016 20:23:03 +0300

>    Here's the set of 5 patches against DaveM's 'net-next.git' repo. The first
> patch makes get_phy_device() return only error values on error, the rest of
> the patches clean up the callers of that function...

Series applied, thanks.
