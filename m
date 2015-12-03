From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v3 00/28] bonding/team offload + mlxsw
 implementation
Date: Thu, 03 Dec 2015 11:51:40 -0500 (EST)
Message-ID: <20151203.115140.1992432368275148930.davem@davemloft.net>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41295 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009AbbLCQvn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:51:43 -0500
In-Reply-To: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Thu,  3 Dec 2015 12:12:02 +0100

> This patchset introduces needed infrastructure for link aggregation
> offload - for both team and bonding. It also implements the offload
> in mlxsw driver.

Series applied, please send followups that do the const'ing Eric Dumazet
asked for.

Thanks.
