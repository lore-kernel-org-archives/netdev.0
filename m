From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Thu, 22 Oct 2015 07:41:16 -0700 (PDT)
Message-ID: <20151022.074116.2063486490315211774.davem@davemloft.net>
References: <1445522558-5808-1-git-send-email-mans@mansr.com>
	<1445522558-5808-3-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1445522558-5808-3-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mans Rullgard <mans@mansr.com>
Date: Thu, 22 Oct 2015 15:02:38 +0100

> This adds a driver for the Aurora VLSI NB8800 Ethernet controller.
> It is an almost complete rewrite of a driver originally found in
> a Sigma Designs 2.6.22 tree.
> 
> Signed-off-by: Mans Rullgard <mans@mansr.com>

The netdev list is going to have to see patches #1 and #2 as well as
your cover letter in order to review and integrate this driver
properly.
