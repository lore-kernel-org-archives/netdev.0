From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Pull request: bluetooth-next-2.6 2009-06-08
Date: Tue, 09 Jun 2009 17:25:20 +0200
Message-ID: <1244561120.3068.17.camel@localhost.localdomain>
References: <1244466304.24950.4.camel@localhost.localdomain>
	 <20090608.142440.129404475.davem@davemloft.net>
	 <1244526163.3068.1.camel@localhost.localdomain>
	 <20090608.234701.51739911.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:40423 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751063AbZFIPZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 11:25:20 -0400
In-Reply-To: <20090608.234701.51739911.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> >> > these are the Bluetooth patches for the 2.6.31 kernel release. They are
> >> > mostly cleanups and removal of dead/unused code. However we do integrate
> >> > with the re-written RFKILL subsystem now. This gives us proper soft-kill
> >> > support for internal and external devices.
> >> 
> >> Where is the attached patch we talked about the other week
> >> so that your pull requests get tracked in patchwork?
> > 
> > I thought you wanted it only for the net-2.6 pull requests and not for
> > the net-next-2.6 ones. Do you want them for both?
> 
> If the diff is small enough to fit on the list, do them for both.
> 
> If it's a lot of new stuff and huge, you can pass on it.

no problem. Do you want me to re-send this one or are you planning to
pull it like it is.

I am trying to cleanup the Marvell Bluetooth driver and get it compiler
warning free so that can be merged too. If you want me to re-send it
with patches attached, then I might do it before the weekend to include
that driver. Otherwise please pull this one.

Regards

Marcel


