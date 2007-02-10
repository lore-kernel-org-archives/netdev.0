From: Michael Buesch <mb@bu3sch.de>
Subject: Re: The new SSB subsystem for bcm43xx (and others)
Date: Sat, 10 Feb 2007 22:03:57 +0100
Message-ID: <200702102203.57411.mb@bu3sch.de>
References: <200612221359.25093.mb@bu3sch.de> <20070210204630.GA27274@srcf.ucam.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: bcm43xx-dev@lists.berlios.de, netdev@vger.kernel.org,
	Felix Fietkau <nbd@nbd.name>
To: Matthew Garrett <mjg59@srcf.ucam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:34736
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbXBJVEK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Feb 2007 16:04:10 -0500
In-Reply-To: <20070210204630.GA27274@srcf.ucam.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Saturday 10 February 2007 21:46, Matthew Garrett wrote:
> I'm testing with your bcm43xx git tree, which I'm guessing is the 
> current ssb code. The only problem I've found is that there doesn't seem 
> to be any sysfs relationship between the ssb bus and (in this case) the 
> PCI device that it's associated with. Is this fixable? Right now it 
> appears as an entirely separate branch of the device tree, which doesn't 
> seem quite right.

I guess that's fixable, but I didn't care too much, yet.

-- 
Greetings Michael.
