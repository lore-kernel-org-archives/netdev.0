From: Martin Devera <devik@cdi.cz>
Subject: Re: PSCHED_GET_TIME related bug: jiffies wraparound
Date: Thu, 23 May 2002 17:22:16 +0200 (CEST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0205231705160.788-100000@luxik.cdi.cz>
References: <200205231444.SAA11574@sex.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200205231444.SAA11574@sex.inr.ac.ru>
List-Id: netdev.vger.kernel.org

Hello,

> > I hope the 0xffffffff change will go into pre9.
>
> Did Dave ack that patch? I did not resend it, to be honest.

He didn't (at least not to me). I've to admit I've no experience
with submitting patches to main kernel. A sent them to you because
you are author of these parts and I haven't wanted to bypass you.

> > I've another potential bug for you ;)
>
> OK. I will pack both of them.

Thanks. I should say that I didn't tested the change extensively but
seems to work (I didn't tested it 497 days however :).
Probably the change is simple enough to be validated at the first
sight.
