From: Jean-Christophe Dubois <jcd@tribudubois.net>
Subject: Re: network card with inline crypto engine?
Date: Tue, 19 Aug 2008 21:10:07 +0200
Message-ID: <200808192110.08500.jcd@tribudubois.net>
References: <804fd2027cd558087a3db013b9ec80af@91.121.53.53> <335b1a8e57d24608fae99045a49cb70b@91.121.53.53> <1219168299.15135.15.camel@lap75545.ornl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:33812 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753960AbYHSTKM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 15:10:12 -0400
In-Reply-To: <1219168299.15135.15.camel@lap75545.ornl.gov>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks David,

Out of curiosity, did you maintain you patch since 2.6.10/2.6.12? It se=
ems you=20
were integrating comments but I don't think there has been a second=20
submission from you. It would be too bad to let it get lost.

As for the fact that it is not perfect yet, it just leave room for=20
improvement. ;-)

Regards

JC

Le Tuesday 19 August 2008 19:51:39 David Dillow, vous avez =E9crit=A0:
> On Tue, 2008-08-19 at 16:38 +0200, Jean-Christophe DUBOIS wrote:
> > Thanks Dave,
> >
> > I guess you are refering to this proposal:
> >
> > http://oss.sgi.com/archives/netdev/2005-01/msg00347.html
> >
> > And nothing is in the plan at the moment?
>
> I assume that's the one he's referring to. I started reworking it, bu=
t
> then life intervened. I'd like to finish it off, but it seems somewha=
t
> pointless now with the Typhoon cards.
>
> I'd differ on the usable, but he's right it wasn't the cleanest
> possible.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


