From: Jens =?iso-8859-1?q?K=FCbler?= <cleanerx@au.hadiko.de>
Subject: Re: nforce2 keeps crashing with 2.4.27pre3
Date: Thu, 27 May 2004 13:01:39 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405271301.39344.cleanerx@au.hadiko.de>
References: <200405261756.35333.cleanerx@au.hadiko.de> <20040526190735.A6244@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org
In-Reply-To: <20040526190735.A6244@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> [r8169 dysfunction on 2.4.27-pre3]
> http://www.fr.zoreil.com/people/francois/misc/20040526-2.4.27-pre3-r816=
9.c-
>test.patch
> Please report further success/failure on netdev@oss.sgi.com

Hi

I have applied the patch and my system is now stable even when heavy netw=
ork=20
traffic appears. I enabled NAPI for the card. The network througput is st=
ill=20
a bit low (~12MB/s) but I guess this is due to the unpatched endpoint whi=
ch=20
is also rtl8169 because bonnie told me both harddrives of the computers a=
re=20
capable of more than that.
System temperature dropped by 13=B0 (from 55=B0) when idle for those inte=
rested in=20
test results.

Thanx for help

Jens
