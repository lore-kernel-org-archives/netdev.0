From: David Miller <davem@davemloft.net>
Subject: Re: [patch] rocker: fix rocker_world_port_obj_vlan_add()
Date: Tue, 23 Feb 2016 13:12:53 -0500 (EST)
Message-ID: <20160223.131253.1345433336482609987.davem@davemloft.net>
References: <20160223093752.GA4030@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, sfeldma@gmail.com, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20160223093752.GA4030@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 23 Feb 2016 12:37:52 +0300

> We were changing return values and accidentally made
> rocker_world_port_obj_vlan_add() into a no-op.
> 
> Fixes: fccd84d44912 ('rocker: return -EOPNOTSUPP for undefined world ops')
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
