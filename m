From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sky2: override for PCI legacy power management
Date: Wed, 21 Mar 2012 16:56:36 -0400 (EDT)
Message-ID: <20120321.165636.369272291402056641.davem@davemloft.net>
References: <4F69BE2E.7070903@t-online.de>
	<20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Knut_Petersen@t-online.de, torvalds@linux-foundation.org,
	arekm@maven.pl, nitro@legroom.net, dilieto@lineone.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120321083205.360a7a3b@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 21 Mar 2012 08:32:05 -0700

> Some BIOS's don't setup power management correctly (what else is
> new) and don't allow use of PCI Express power control. Add a special
> exception module parameter to allow working around this issue.
> Based on slightly different patch by Knut Petersen.
> 
> Reported-by: Arkadiusz Miskiewicz <arekm@maven.pl>
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied and queued up for -stable.
