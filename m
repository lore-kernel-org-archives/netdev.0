From: "Holger Hoffstaette" <holger@wizards.de>
Subject: Re: Nasty regression from .27.7 to .27.8: idle samba goes crazy
Date: Mon, 08 Dec 2008 21:08:41 +0100
Message-ID: <pan.2008.12.08.20.08.41.100500@wizards.de>
References: <pan.2008.12.08.06.18.57.357875@wizards.de> <200812080834.22924.rjw@sisk.pl> <pan.2008.12.08.08.07.29.439625@wizards.de> <493D4F5C.7020606@s5r6.in-berlin.de> <493D7349.10200@s5r6.in-berlin.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:53846 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751463AbYLHUI7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Dec 2008 15:08:59 -0500
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1L9mPV-000690-A6
	for netdev@vger.kernel.org; Mon, 08 Dec 2008 20:08:53 +0000
Received: from port-87-234-136-62.dynamic.qsc.de ([87.234.136.62])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 20:08:53 +0000
Received: from holger by port-87-234-136-62.dynamic.qsc.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 08 Dec 2008 20:08:53 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 08 Dec 2008 20:19:37 +0100, Stefan Richter wrote:

>>>> On Monday, 8 of December 2008, Holger Hoffstaette wrote:
>>>>> The system is a generic old single-core P4 box with a single SATA
>>>>> drive, Gentoo userland and Samba is 3.0.33 (in async mode). The
>>>>> kernel has no patches or binary drivers.
> 
> Holger, it may be unrelated to the issue, but to be sure:  Which network
> card driver do you use?

e1000 with the older PCI/PCI-X 82545GM rev.04 card in a PCI slot.

thanks,
Holger


