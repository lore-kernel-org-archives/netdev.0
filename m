From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atm: simplify lanai.c by using module_pci_driver
Date: Fri, 17 Oct 2014 11:55:45 -0400 (EDT)
Message-ID: <20141017.115545.263842180599038435.davem@davemloft.net>
References: <1413359150-13552-1-git-send-email-michael.opdenacker@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: michael.opdenacker@free-electrons.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1413359150-13552-1-git-send-email-michael.opdenacker@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Date: Wed, 15 Oct 2014 09:45:50 +0200

> This simplifies the lanai.c driver by using
> the module_pci_driver() macro, at the expense
> of losing only debugging messages.
> 
> Signed-off-by: Michael Opdenacker <michael.opdenacker@free-electrons.com>

Applied, thanks.
