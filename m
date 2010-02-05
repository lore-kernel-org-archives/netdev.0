From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC 0/4] bond hashing revised
Date: Fri, 5 Feb 2010 13:04:33 -0800
Message-ID: <20100205130433.16fc307f@nehalam>
References: <20100204171118.917737392@vyatta.com>
	<4B6BE781.7070107@fox-it.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bonding-devel@lists.sourceforge.net"
	<bonding-devel@lists.sourceforge.net>
To: Jasper Spaans <spaans@fox-it.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53911 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757504Ab0BEVEu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2010 16:04:50 -0500
In-Reply-To: <4B6BE781.7070107@fox-it.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 5 Feb 2010 09:40:17 +0000
Jasper Spaans <spaans@fox-it.com> wrote:

> On 04/02/10 17:11, Stephen Hemminger wrote:
> > These have not been tested yet. I need to try them with some
> > different flows/hardware to validate.
> >   
> Glancing over these patches, all four of them look fine to me.
> 
> The only thing missing is some documentation in
> Documentation/networking/bonding.txt (I have no idea what multiqueue is
> supposed to do, but if you tell me I'll volunteer).
> 

Did you look at kernel Documentation/networking/multiqueue.txt?
