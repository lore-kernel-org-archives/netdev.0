From: Pekka Savola <pekkas@netcore.fi>
Subject: Re: 2.4.21+ - IPv6 over IPv4 tunneling b0rked
Date: Wed, 16 Jul 2003 09:03:57 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0307160901560.20100-100000@netcore.fi>
References: <200307152319.DAA09683@dub.inr.ac.ru>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@redhat.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
In-Reply-To: <200307152319.DAA09683@dub.inr.ac.ru>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 kuznet@ms2.inr.ac.ru wrote:
> > Assume you're a host on a link with prefix 3FFE:FFFF:A:B::/64.  The router 
> > is the one with interface ID one.
> 
> Not going to work. Host autoconfiguration conventions have nothing
> to do with real addressing. Proceeding in this way you will denounce
> neighbour discovery, what the hell to do this when hw address can be recovered
> from EUI64 token? :-)

Did you miss the word "Assume" ?

> > What happens when you do "ping6 3FFE:FFFF:A:B::1" ?
> 
> Hey, you have lost track, rewind several mails ago. 

Nope.  I'm just pointing out the general concept.

> Of course, ping and
> any other protocols will work, how can it not work? :-)

It has been made shown to work on other platforms, so why not Linux?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
