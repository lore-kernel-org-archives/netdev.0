From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC PATCH 0/1] BPF JIT for PPC64
Date: Sat, 25 Jun 2011 09:33:31 +1000
Message-ID: <1308958411.32158.335.camel@pasglop>
References: <4E042867.5020902@ozlabs.org>
	 <750BF3E9-A788-4302-8AA1-4630614E20DC@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Matt Evans <matt@ozlabs.org>, netdev@vger.kernel.org,
	linuxppc-dev <linuxppc-dev@lists.ozlabs.org>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:35589 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754901Ab1FXXdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Jun 2011 19:33:42 -0400
In-Reply-To: <750BF3E9-A788-4302-8AA1-4630614E20DC@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-06-24 at 04:16 -0500, Kumar Gala wrote:
> > Tested in-situ (tcpdump with varying complexity filters) and with a random BPF
> > generator; I haven't verified loads from the fall back skb_copy_bits path.  Bug
> > reports/testing would be very welcome.
> 
> Would be nice to get PPC32 support as well. 

Patches welcome :-)

Cheers,
Ben.


