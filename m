From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Fix Prefix Length of Link-local Addresses
Date: Thu, 10 Oct 2002 00:47:24 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200210092047.AAA20234@sex.inr.ac.ru>
References: <20021010.042333.122713397.yoshfuji@wide.ad.jp>
Mime-Version: 1.0
Cc: pekkas@netcore.FI, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@wide.ad.jp (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20021010.042333.122713397.yoshfuji@wide.ad.jp> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Oct 10, 2 04:23:33 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> How about this (against 2.4.19 / 2.4.20-pre10)?

It can be made global added at ipv6_route_init, I think.

Alexey
