From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH] [NET] [TG3] Convert the pci_device_it table to
 PCI_DEVICE()
Date: Fri, 18 Aug 2006 15:48:41 -0700
Message-ID: <1155941321.4201.1.camel@rh4>
References: <44E195B2.3070406@nachtwindheim.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:11789 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1751565AbWHRWtH
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Aug 2006 18:49:07 -0400
To: "Henne" <henne@nachtwindheim.de>
In-Reply-To: <44E195B2.3070406@nachtwindheim.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-15 at 11:36 +0200, Henne wrote:
> From: Henrik Kretzschmar <henne@nachtwindheim.de>
> 
> Convert the pci_device_ids to PCI_DEVICE() macro.
> Saves 1.5k in the sourcefile.
> 
> Signed-off-by: Henrik Kretzschmar <henne@nachtwindheim.de>
> ---

Acked-by: Michael Chan <mchan@broadcom.com>


