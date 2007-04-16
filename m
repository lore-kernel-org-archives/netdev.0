From: David Acker <dacker@roinet.com>
Subject: Re: [RFT] e100 driver on ARM
Date: Mon, 16 Apr 2007 11:07:36 -0400
Message-ID: <46239138.4040408@roinet.com>
References: <44FC0261.6010807@garzik.org> <20060904123123.GB1285@xi.wantstofly.org> <460AF480.7050609@intel.com> <460B4BF2.1070803@roinet.com> <20070329141041.GA3510@csclub.uwaterloo.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Jeff Garzik <jeff@garzik.org>,
	Netdev List <netdev@vger.kernel.org>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Lennart Sorensen <lsorense@csclub.uwaterloo.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-72-92-88-10.phlapa.fios.verizon.net ([72.92.88.10]:46353
	"EHLO smtp.roinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752844AbXDPPFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 11:05:50 -0400
In-Reply-To: <20070329141041.GA3510@csclub.uwaterloo.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennart Sorensen wrote:
> Which PCI host controller are you using with the PXA255?  We tried using
> a PXA255 based system with a PCI controller a couple of years ago and
> have to change to a different cpu in the end due to the PCI controller
> simply not being valid PCI.  The PXA255 wasn't designed for PCI, and I
> get the impression that non of the PCI companion chips for it do a good
> enough job to actually add it correctly.
> 

Sorry for the delay in responding...my wife and I just had twins!

We are using the IT8152G RISC-to-PCI companion chip.
-Ack
