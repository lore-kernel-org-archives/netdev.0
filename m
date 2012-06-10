From: =?ISO-8859-1?Q?Alex_Villac=EDs_Lasso?= <a_villacis@palosanto.com>
Subject: Re: REGRESSION: 3.4.0->3.5.0-rc2 kernel WARNING on cable plug on
 Acer Aspire One, no network
Date: Sun, 10 Jun 2012 15:34:34 -0500
Message-ID: <4FD504DA.3000500@palosanto.com>
References: <4FD4F28B.4070003@palosanto.com> <20120610195906.GA15641@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.palosanto.com ([201.234.196.171]:51728 "EHLO
	pbx.palosanto.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab2FJUeo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jun 2012 16:34:44 -0400
In-Reply-To: <20120610195906.GA15641@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

El 10/06/12 14:59, Francois Romieu escribi=F3:
> Alex Villac=EDs Lasso<a_villacis@palosanto.com>  :
> [...]
>
> Which r8169 chipset version is it (dmesg | grep XID) ?
>
$ grep XID dmesg-3.5.0-rc2.txt
[   15.873858] r8169 0000:02:00.0: eth0: RTL8102e at 0xf7c0e000,=20
00:1e:68:e5:5d:b1, XID 04a00000 IRQ 44
