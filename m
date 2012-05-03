From: =?UTF-8?B?QWxleCBWaWxsYWPDrcKtcyBMYXNzbw==?=
	<avillaci@ceibo.fiec.espol.edu.ec>
Subject: Re: Fwd: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x277/0x280()
Date: Wed, 02 May 2012 19:44:04 -0500
Message-ID: <4FA1D4D4.8040208@ceibo.fiec.espol.edu.ec>
References: <20120502225227.GA12309@electric-eye.fr.zoreil.com> <4FA1C34C.6080909@fiec.espol.edu.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([200.93.199.101]:42620 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753795Ab2ECBQc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 21:16:32 -0400
In-Reply-To: <4FA1C34C.6080909@fiec.espol.edu.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 02/05/12 18:29, Alex Villac=C3=AD=C2=ADs Lasso escribi=C3=B3:
>
> Alex Villac=C3=AD=C2=ADs Lasso<avillaci@fiec.espol.edu.ec>  :
> [...]
> >  Still present in 3.4-rc5.
>
> Is it a 8168evl ?
>
> --=20
> Ueimor
>
lspci -vnn:

02:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd.=20
RTL8111/8168B PCI Express Gigabit Ethernet controller [10ec:8168] (rev =
01)
     Subsystem: Foxconn International, Inc. Device [105b:0ded]
     Flags: bus master, fast devsel, latency 0, IRQ 43
     I/O ports at ee00 [size=3D256]
     Memory at fdcff000 (64-bit, non-prefetchable) [size=3D4K]
     [virtual] Expansion ROM at fdb00000 [disabled] [size=3D128K]
     Capabilities: <access denied>
     Kernel driver in use: r8169
     Kernel modules: r8169

Integrated motherboard chipset.
