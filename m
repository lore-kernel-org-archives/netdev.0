From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch] rocker: fix an error code
Date: Sat, 27 Feb 2016 12:38:35 +0100
Message-ID: <20160227113835.GD2119@nanopsycho.orion>
References: <20160227113143.GA19177@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ying Xue <ying.xue@windriver.com>,
	Scott Feldman <sfeldma@gmail.com>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160227113143.GA19177@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sat, Feb 27, 2016 at 12:31:43PM CET, dan.carpenter@oracle.com wrote:
>We intended to return PTR_ERR() here instead of 1.
>
>Fixes: 1f9993f6825f ('rocker: fix a neigh entry leak issue')
>Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Jiri Pirko <jiri@mellanox.com>
