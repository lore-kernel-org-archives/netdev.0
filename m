From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] skge: restore multicast rx filter on resume
Date: Thu, 29 Dec 2011 08:18:46 -0800
Message-ID: <20111229081846.04eb0c63@nehalam.linuxnetplumber.net>
References: <20111228092714.0a6d5f80@nehalam.linuxnetplumber.net>
	<20111228.130908.182833189468208987.davem@davemloft.net>
	<20111229064849.GB8041@florz.florz.dyndns.org>
	<20111229.025611.2043166821951238153.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: florz@florz.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:51229 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753270Ab1L2QSu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 11:18:50 -0500
In-Reply-To: <20111229.025611.2043166821951238153.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Dec 2011 02:56:11 -0500 (EST)
David Miller <davem@davemloft.net> wrote:

> From: Florian Zumbiehl <florz@florz.de>
> Date: Thu, 29 Dec 2011 07:48:50 +0100
> 
> > --- a/drivers/net/skge.c
> > +++ b/drivers/net/skge.c  
> 
> This file no longer exists in the current source tree.

Florian the driver has moved to:
  drivers/net/ethernet/marvell/skge.c
in latest kernel release.
