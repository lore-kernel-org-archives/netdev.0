From: Bart De Schuymer <bdschuym@pandora.be>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Thu, 18 Nov 2004 20:59:38 +0100
Message-ID: <200411182059.38445.bdschuym@pandora.be>
References: <20041115122046.1413527e.akpm@osdl.org> <20041115124843.4c3dd72f.akpm@osdl.org> <419C8724.20006@uznam.net.pl>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?utf-8?q?Micha=C5=82=20Margula?= <alchemyx@uznam.net.pl>,
        Andrew Morton <akpm@osdl.org>
In-Reply-To: <419C8724.20006@uznam.net.pl>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 18 November 2004 12:27, Micha=C5=82 Margula wrote:
> >Bart De Schuymer <bdschuym@pandora.be> wrote:
> >>>Problem is present in 2.6.8.1 and 2.6.9 kernels. There was no such
> >>> problem on 2.4.26.
> >>
> >>Can you do something similar with iptables rules to see if it's speci=
fic
> >> to ebtables (which I doubt)?
>
> Over 50 hours after converting rules from ebtables to iptables and stil=
l
> no lockup. Everything is fine and I am sure it will go stable for days
> (as mentioned before lockup with ebtables happens in less than 24 hours=
).

OK. As far as I know the ebtables code in 2.6 and the code in the 2.4 pat=
ch=20
are equivalent. I'll get back to you (too busy right now).

Bart
