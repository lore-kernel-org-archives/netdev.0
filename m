From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bfin_mac: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 23:27:25 -0400 (EDT)
Message-ID: <20130912.232725.1627585832402702765.davem@davemloft.net>
References: <1378956943-3470-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: richardcochran@gmail.com, jg1.han@samsung.com, jiri@resnulli.us,
	mugunthanvnm@ti.com, uclinux-dist-devel@blackfin.uclinux.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378956943-3470-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Thu, 12 Sep 2013 05:35:43 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/adi/bfin_mac.c.
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
