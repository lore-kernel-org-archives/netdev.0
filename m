From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: remove oflags from setlink/dellink.
Date: Mon, 19 Jan 2015 01:23:06 -0500 (EST)
Message-ID: <20150119.012306.1400659138779458736.davem@davemloft.net>
References: <1421660704-5122-1-git-send-email-rami.rosen@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	hemminger@vyatta.com
To: rami.rosen@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52866 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbbASGXK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2015 01:23:10 -0500
In-Reply-To: <1421660704-5122-1-git-send-email-rami.rosen@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rami Rosen <rami.rosen@intel.com>
Date: Mon, 19 Jan 2015 11:45:04 +0200

> Commit 02dba4388d16 ("bridge: fix setlink/dellink notifications") removed usage of oflags in 
> both rtnl_bridge_setlink() and rtnl_bridge_dellink() methods. This patch removes this variable as it is no 
> longer needed.
> 
> Signed-off-by: Rami Rosen <rami.rosen@intel.com>

Applied, thanks.
