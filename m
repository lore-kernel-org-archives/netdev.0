From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2 v4] s2io: add PCI error recovery support
Date: Mon, 21 May 2007 14:48:47 -0700
Message-ID: <20070521144847.439103c4.akpm@linux-foundation.org>
References: <20070521185853.GD5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Sivakumar Subramani <sivakumar.subramani@neterion.com>,
	Sreenivasa Honnur <sreenivasa.honnur@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Wen Xiong <wenxiong@us.ibm.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org
To: linas@austin.ibm.com (Linas Vepstas)
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52075 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758069AbXEUVy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 17:54:29 -0400
In-Reply-To: <20070521185853.GD5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 21 May 2007 13:58:53 -0500
linas@austin.ibm.com (Linas Vepstas) wrote:

> This patch adds PCI error recovery support to the 
> s2io 10-Gigabit ethernet device driver. Fourth revision,
> blocks MSI interrupts, and statistics gathering, as well.
> 
> Tested, seems to work well.
> 
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> Acked-by: Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>
> Cc: Sivakumar Subramani <sivakumar.subramani@neterion.com>
> Cc: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>
> Cc: Rastapur Santosh <santosh.rastapur@neterion.com>
> Cc: Wen Xiong <wenxiong@us.ibm.com>
> 
> ----
> Please apply. This has been submitted for 2.6.19, 2.6.20 and 2.6.21
> with no major criticisms made, although with minor polish & fixups.
> I think its ready.

This is already in Jeff's development tree.  Your new patch neither
applies nor unapplies, so if you've changed it, Jeff is now sitting
on an old version.  I assume he'd like an incremental update patch.

