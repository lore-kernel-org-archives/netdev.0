From: James Corey <ploversegg@yahoo.com>
Subject: Re: 2.6.23-rc3 and SKY2 driver issue
Date: Mon, 20 Aug 2007 09:23:46 -0700 (PDT)
Message-ID: <624025.57129.qm@web90408.mail.mud.yahoo.com>
References: <20070820090227.6ceb2934@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web90408.mail.mud.yahoo.com ([216.252.100.160]:22125 "HELO
	web90408.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1759337AbXHTQXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Aug 2007 12:23:51 -0400
In-Reply-To: <20070820090227.6ceb2934@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--- Stephen Hemminger
<shemminger@linux-foundation.org> wrote:

> On Mon, 20 Aug 2007 08:42:21 -0700 (PDT)
> James Corey <ploversegg@yahoo.com> wrote:
> 
> > 
> > --- Stephen Hemminger
> > <shemminger@linux-foundation.org> wrote:
> > 
> > > On Thu, 16 Aug 2007 10:25:45 +0200
> > > "Michal Piotrowski"
> >
> > > Please reproduce with a more recent kernel?
> > 
> > Um, I thought 2.6.23rc WAS pretty recent. :-)
> > 
> > I'll check if there is something newer in the
> > repository now.
> > 
> 
> What is the chip version?  Please send console log:
> "dmesg | grep sky2"
> 
> 
> -- 
> Stephen Hemminger <shemminger@linux-foundation.org>
> 


Ah ... details.

Machine: 

Dell Optiplex 745

Kernel:

2.6.23-rc3 #1 SMP Tue Aug 14 19:44:07 EDT 2007 x86_64
x86_64 x86_64 GNU/Linux

Card:

D-Link DGE-550SX

# dmesg | grep sky2
sky2 0000:04:00.0: v1.16 addr 0xdf9fc000 irq 16
Yukon-XL (0xb3) rev 3
sky2 eth1: addr 00:17:9a:73:87:60
sky2 eth1: enabling interface
sky2 eth1: ram buffer 96K
sky2 eth1: Link is up at 1000 Mbps, full duplex, flow
control none




       
____________________________________________________________________________________
Be a better Globetrotter. Get better travel answers from someone who knows. Yahoo! Answers - Check it out.
http://answers.yahoo.com/dir/?link=list&sid=396545469
