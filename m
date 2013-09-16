From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc: remove deprecated IRQF_DISABLED
Date: Mon, 16 Sep 2013 00:56:03 -0400 (EDT)
Message-ID: <20130916.005603.1637895861320960927.davem@davemloft.net>
References: <1379046467-6900-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, will.deacon@arm.com
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379046467-6900-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Fri, 13 Sep 2013 06:27:47 +0200

> This patch proposes to remove the IRQF_DISABLED flag from
> code in drivers/net/ethernet/smsc/
> 
> It's a NOOP since 2.6.35 and it will be removed one day.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied.
