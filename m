From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next V2] drivers/net: Remove casts of void *
Date: Tue, 21 Jun 2011 11:45:34 -0700
Message-ID: <1308681934.3338.17.camel@Joe-Laptop>
References: <3bea9d0803a4ebfee2bb0f6e42defbf76126dc86.1308287030.git.joe@perches.com>
	 <20110617.151903.1203335395245647912.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110617.151903.1203335395245647912.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2011-06-17 at 15:19 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com>
> Date: Thu, 16 Jun 2011 22:08:06 -0700
> > Unnecessary casts of void * clutter the code.
> > These are the remainder casts after several specific
> > patches to remove netdev_priv and dev_priv.
> > Done via coccinelle script (and a little editing):
> Applied, thanks.

Unapplied?  I don't see this in net-next.
