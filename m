From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] IPv6: Refine IPv6 Address Validation Timer
Date: Fri, 27 Sep 2002 20:39:45 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209271639.UAA21514@sex.inr.ac.ru>
References: <20020928.011439.108856769.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Cc: davem@redhat.com, linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=)
In-Reply-To: <20020928.011439.108856769.yoshfuji@linux-ipv6.org> from "YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=" at Sep 28, 2 01:14:39 am
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> (*) Oops, I slipped at (almost) end of the patch when making patch... sorry;
> I inteded to refine timing into ~0.5 sec at worst;

Does this matter? What is special about 0.5sec comparing to 1?

> (do I need to resend complete patch?)

No, I think. Deletion of bad debugging is easier to make after patching.

Alexey
