From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch -next] mlxsw: spectrum: fix some error handling
Date: Wed, 9 Dec 2015 11:47:20 +0100
Message-ID: <20151209104720.GA2340@nanopsycho.orion>
References: <20151209103351.GI3173@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Ido Schimmel <idosch@mellanox.com>,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151209103351.GI3173@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Dec 09, 2015 at 11:33:51AM CET, dan.carpenter@oracle.com wrote:
>The "err = " assignment is missing here.
>
>Fixes: 0d65fc13042f ('mlxsw: spectrum: Implement LAG port join/leave')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>

Thanks.
