From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Fri, 27 Sep 2002 19:46:55 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271546.TAA21299@sex.inr.ac.ru>
References: <3D947BDB.2010007@candelatech.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com (Ben Greear)
In-Reply-To: <3D947BDB.2010007@candelatech.com> from "Ben Greear" at Sep 27, 2 08:40:11 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> It will not match the case where the sending socket is bound to interface 3
> and the listening socket is bound on interface 4, but both sockets have the
> same source IP and port.  That was what I was trying
> to do...but I may have not done it quite right :)

I would say "quite not right". :-)

Anyway, this is supposed to work without any modifications.

Alexey
