From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ehea: remove deprecated IRQF_DISABLED
Date: Thu, 12 Sep 2013 23:27:30 -0400 (EDT)
Message-ID: <20130912.232730.989393355906394114.davem@davemloft.net>
References: <1378957571-3574-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: cascardo@linux.vnet.ibm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378957571-3574-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Thu, 12 Sep 2013 05:46:11 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> drivers/net/ethernet/ibm/ehea/ehea_main.c
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
