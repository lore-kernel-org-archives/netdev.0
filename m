From: Andrew Morton <akpm@osdl.org>
Subject: Re: Patch to add ethtool -g to Spidernet network driver
Date: Mon, 14 Aug 2006 11:14:32 -0700
Message-ID: <20060814111432.d496f4d3.akpm@osdl.org>
References: <1154792185.3692.68.camel@localhost.localdomain>
	<44E0BAB2.6090800@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jim@jklewis.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:26027 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752037AbWHNSSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2006 14:18:31 -0400
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <44E0BAB2.6090800@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 Aug 2006 14:02:26 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Jim Lewis wrote:
> > 
> > This patch adds ethtool -g (show ring sizes) support to the Spidernet
> > network driver.
> > 
> > Signed-off-by: James K Lewis <jklewis@us.ibm.com>
> 
> ACK, but does not apply:

I added it to rc4-mm1.  I probably fixed it up by hand - I forget - it
happens so often :(

I have a really large pile of patches to send out to the subsystem
maintainers, so this'll be coming back at you soon via that route.


