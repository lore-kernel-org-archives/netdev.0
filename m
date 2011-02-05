From: chriss <mail_to_chriss@gmx.net>
Subject: Re: 2.6.37 regression: adding main interface to a bridge breaks vlan interface RX
Date: Sat, 5 Feb 2011 15:34:33 +0000 (UTC)
Message-ID: <loom.20110205T163216-459@post.gmane.org>
References: <4D32FC1C.3010905@simon.arlott.org.uk> <201101231845.20505.maciej.rutecki@gmail.com> <AANLkTimTz=kMmJ=YhyJv28WUrsbN=ygBt9e7dMJ3KGqB@mail.gmail.com> <201101241625.45367.maciej.rutecki@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:46327 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751657Ab1BEPkH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Feb 2011 10:40:07 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1PlkF3-00087f-Rt
	for netdev@vger.kernel.org; Sat, 05 Feb 2011 16:40:05 +0100
Received: from HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de ([109.193.65.201])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 05 Feb 2011 16:40:05 +0100
Received: from mail_to_chriss by HSI-KBW-109-193-065-201.hsi7.kabel-badenwuerttemberg.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 05 Feb 2011 16:40:05 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maciej Rutecki <maciej.rutecki <at> gmail.com> writes:

> 
> On niedziela, 23 stycznia 2011 o 22:29:02 Jesse Gross wrote:
> > On Sun, Jan 23, 2011 at 9:45 AM, Maciej Rutecki
> > 
> > <maciej.rutecki <at> gmail.com> wrote:
> > > I created a Bugzilla entry at
> > > https://bugzilla.kernel.org/show_bug.cgi?id=27432
> > > for your bug report, please add your address to the CC list in there,
> > > thanks!
> > 
> > This isn't a bug - the change resolved behavior that varied depending
> > on what NIC was in use.
> 
> Thanks for the update. Closing.
> 
> Regards


Hi

How am i supposed to put my eth to a bridge and have a seprate vlan besides that
bridge?

regards

