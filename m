From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH net-next 1/1] net: fec: clear receive interrupts before
 processing a packet
Date: Wed, 2 Sep 2015 10:46:58 +0100
Message-ID: <20150902094658.GO21084@n2100.arm.linux.org.uk>
References: <1441185854-16107-1-git-send-email-b38611@freescale.com>
 <20150902094015.GA27372@frolo.macqel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fugang Duan <b38611@freescale.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Philippe De Muyter <phdm@macq.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:44834 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750971AbbIBJrI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 05:47:08 -0400
Content-Disposition: inline
In-Reply-To: <20150902094015.GA27372@frolo.macqel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 02, 2015 at 11:40:15AM +0200, Philippe De Muyter wrote:
> On Wed, Sep 02, 2015 at 05:24:14PM +0800, Fugang Duan wrote:
> > From: Russell King <rmk+kernel@arm.linux.org.uk>
> > 
> > The patch just to re-submit the patch "db3421c114cfa6326" because the
> > patch "4d494cdc92b3b9a0" remove the change.
> 
> I think you should mention also the titles of the commits.

Yes, that's standard kernel procedure.  Also, 12 characters of commit ID
is the recommended length.

> Could a comment be added here to avoid another future removal ?

I think reading the commit messages introducing the code would also help,
but a comment wouldn't hurt.

-- 
FTTC broadband for 0.8mile line: currently at 9.6Mbps down 400kbps up
according to speedtest.net.
