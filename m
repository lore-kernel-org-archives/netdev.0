From: jamal <hadi@cyberus.ca>
Subject: Re: Improvements in FreeBSD 5.3 networking
Date: 05 Sep 2004 08:15:25 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1094386350.1340.6.camel@jzny.localdomain>
References: <20040905094636.GA10086@irc.pl>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, "David S. Miller" <davem@redhat.com>,
        Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-bounce@oss.sgi.com>
To: Tomasz Torcz <zdzichu@irc.pl>
In-Reply-To: <20040905094636.GA10086@irc.pl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Guess didnt take too long for those BSDers to post on slashdot.
It would be nice for someone to install freebsd and verify the claims
on the routing aspect.
Anyone in Ottawa with BSD expertise drop me a note - I have access to
measurement equipment (and really dont wanna touch BSD if i can avoid it).

cheers,
jamal

PS: We can certainly do better than that on Opterons. Robert
reports a 1.3 Mpps rate on a dual opteron 1.6Ghz. Our numbers on Xeons
are less than 1Mpps. But we can let an old OS like BSD beat us, can we 
now ? ;->

On Sun, 2004-09-05 at 05:46, Tomasz Torcz wrote:
>  Hi,
> 
>  reading Slashdot I'm sutmbled upon presentation of FreeBSD new
> features:
> http://people.freebsd.org/~andre/FreeBSD-5.3-Networking.pdf
> 
>  It look pretty interesting (e.g. tcphostcache), especially they claim
> that FreeBSD on 2.8 GHz Xeon can route 1Mpps.
> 
>  Original slashodt story:
> http://bsd.slashdot.org/article.pl?sid=04/09/04/133253
