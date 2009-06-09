From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: Pull request: bluetooth-next-2.6 2009-06-08
Date: Tue, 09 Jun 2009 07:42:43 +0200
Message-ID: <1244526163.3068.1.camel@localhost.localdomain>
References: <1244466304.24950.4.camel@localhost.localdomain>
	 <20090608.142440.129404475.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:33166 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752120AbZFIFmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 01:42:45 -0400
In-Reply-To: <20090608.142440.129404475.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

> > these are the Bluetooth patches for the 2.6.31 kernel release. They are
> > mostly cleanups and removal of dead/unused code. However we do integrate
> > with the re-written RFKILL subsystem now. This gives us proper soft-kill
> > support for internal and external devices.
> 
> Where is the attached patch we talked about the other week
> so that your pull requests get tracked in patchwork?

I thought you wanted it only for the net-2.6 pull requests and not for
the net-next-2.6 ones. Do you want them for both?

Regards

Marcel


