From: Stephan von Krawczynski <skraw@ithnet.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Wed, 20 Aug 2003 17:55:04 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030820175504.07658147.skraw@ithnet.com>
References: <353568DCBAE06148B70767C1B1A93E625EAB58@post.pc.aspectgroup.co.uk>
	<20030819145403.GA3407@alpha.home.local>
	<20030819170751.2b92ba2e.skraw@ithnet.com>
	<20030819085717.56046afd.davem@redhat.com>
	<20030819185219.116fd259.skraw@ithnet.com>
	<3F43891E.9060204@zurich.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bloemsaa@xs4all.nl, davem@redhat.com, alan@lxorguk.ukuu.org.uk,
   willy@w.ods.org, richard@aspectgroup.co.uk, carlosev@newipnet.com,
   lamont@scriptkiddie.org, davidsen@tmr.com, marcelo@conectiva.com.br,
   netdev@oss.sgi.com, linux-net@vger.kernel.org, layes@loran.com,
   torvalds@osdl.org, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Roman Pletka <rap@zurich.ibm.com>
In-Reply-To: <3F43891E.9060204@zurich.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 20 Aug 2003 16:43:42 +0200
Roman Pletka <rap@zurich.ibm.com> wrote:

> Stephan von Krawczynski wrote:
> > <qoute RFC 1122>
> >       2.3.2  Address Resolution Protocol -- ARP
> > 
> >          2.3.2.1  ARP Cache Validation
> > 
> >             An implementation of the Address Resolution Protocol (ARP)
> >             [LINK:2] MUST provide a mechanism to flush out-of-date cache
> >             entries.  If this mechanism involves a timeout, it SHOULD be
> >             possible to configure the timeout value.
> > 
> > ...
> > 
> > [LINK:2] "An Ethernet Address Resolution Protocol," D. Plummer, RFC-826,
> >      November 1982.
> > 
> > </quote>
> > 
> 
> Please read carefully what you have quoted:
> It says: *An* implementation... and then goes on with a citation of RFC 826.
> A simple citation does not make a valid standard yet. It just refers to it
> as an example for this specific issue. That's all.

Sorry, but my reading is this "An implementation of the ( Address Resolution
Protocol (ARP) [LINK:2] ) ..."
Do you understand what I mean?

If you insist on RFC-826 being only one of several (possible) ARP
implementations, can you then please name an RFC where ARP as a protocol is
clearly defined? I mean there must be one, or not?

Regards,
Stephan
