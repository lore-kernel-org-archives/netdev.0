From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch] rocker: fix rocker_world_port_obj_vlan_add()
Date: Tue, 23 Feb 2016 10:39:48 +0100
Message-ID: <20160223093948.GC2140@nanopsycho.orion>
References: <20160223093752.GA4030@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160223093752.GA4030@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tue, Feb 23, 2016 at 10:37:52AM CET, dan.carpenter@oracle.com wrote:
>We were changing return values and accidentally made
>rocker_world_port_obj_vlan_add() into a no-op.
>
>Fixes: fccd84d44912 ('rocker: return -EOPNOTSUPP for undefined world ops')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Oops. Thanks for the fix.

Acked-by: Jiri Pirko <jiri@mellanox.com>
