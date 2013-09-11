From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: korina: remove deprecated IRQF_DISABLED
Date: Wed, 11 Sep 2013 16:14:59 -0400 (EDT)
Message-ID: <20130911.161459.589536168651227249.davem@davemloft.net>
References: <1378531257-5446-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emilio@elopez.com.ar, mugunthanvnm@ti.com, jg1.han@samsung.com,
	hsweeten@visionengravers.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378531257-5446-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Sat,  7 Sep 2013 07:20:57 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/korina.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
