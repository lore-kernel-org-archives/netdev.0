From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Default Router Selection Round-robin
Date: Wed, 2 Oct 2002 23:22:41 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210021922.XAA26368@sex.inr.ac.ru>
References: <20021003.015057.14743018.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com, davem@redhat.com (Dave Miller)
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.ORG (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20021003.015057.14743018.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Oct 2, 2 09:15:04 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Linux changes default router even while it is probably reachable.
> Once it becomes "non-REACHABLE," Linux trys to select one in round-robin
> fashion, but once it reached end of list, it would be stuck there.

The patch looks perfect.

Alexey
