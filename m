From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [NET] [TG3] Convert the pci_device_it table to
 PCI_DEVICE()
Date: Tue, 22 Aug 2006 00:28:45 -0700 (PDT)
Message-ID: <20060822.002845.08658116.davem@davemloft.net>
References: <44E195B2.3070406@nachtwindheim.de>
	<1155941321.4201.1.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: henne@nachtwindheim.de, akpm@osdl.org, jgarzik@pobox.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:46798
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751335AbWHVH2a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:28:30 -0400
To: mchan@broadcom.com
In-Reply-To: <1155941321.4201.1.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 18 Aug 2006 15:48:41 -0700

> On Tue, 2006-08-15 at 11:36 +0200, Henne wrote:
> > From: Henrik Kretzschmar <henne@nachtwindheim.de>
> > 
> > Convert the pci_device_ids to PCI_DEVICE() macro.
> > Saves 1.5k in the sourcefile.
> > 
> > Signed-off-by: Henrik Kretzschmar <henne@nachtwindheim.de>
> > ---
> 
> Acked-by: Michael Chan <mchan@broadcom.com>

Applied, thanks everyone.
