From: kuznet@ms2.inr.ac.ru
Subject: Re: raw ipv6 broken in 2.4.19
Date: Wed, 14 Aug 2002 17:13:21 +0400 (MSD)
Sender: owner-netdev@oss.sgi.com
Message-ID: <200208141313.RAA23897@sex.inr.ac.ru>
References: <Pine.LNX.4.44.0208140812570.3936-100000@beohost.scyld.com>
Mime-Version: 1.0
Cc: gandalf@wlug.westbo.se, netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: becker@scyld.com (Donald Becker)
In-Reply-To: <Pine.LNX.4.44.0208140812570.3936-100000@beohost.scyld.com> from "Donald Becker" at Aug 14, 2 08:15:47 am
List-Id: netdev.vger.kernel.org

Hello!

> I'm not certain what you mean by this: there are many NIC chips that have
> alignment requirements similar to the Tulip design.

Comparing to _his_ ones.


> Note that the Tulip is no more likely than other cards to trigger
> motherboard PCI implementation bugs.

Donald, it was brain attack. When speaking about alignment we have
already switched to investigation of our checksumming routines.

Alexey
