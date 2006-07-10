From: =?ISO-8859-1?Q?Thomas_Hellstr=F6m?= <thomas@tungstengraphics.com>
Subject: Re: rtl8139: NETDEV WATCHDOG: eth0: transmit timed out
Date: Mon, 10 Jul 2006 15:10:29 +0200
Message-ID: <44B251C5.6060209@tungstengraphics.com>
References: <e82qhq$4v0$1@sea.gmane.org>	<20060630211604.GA5302@electric-eye.fr.zoreil.com> <44AE8CBB.4070409@better.se> <44AFDA3B.6020904@tungstengraphics.com> <44B0AED8.3040604@better.se> <44B0B17D.10803@tungstengraphics.com> <44B24FF6.5060102@better.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org,
	dri-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1-1-8-31a.gmt.gbg.bostream.se ([82.182.75.118]:43505 "EHLO
	lin5.shipmail.org") by vger.kernel.org with ESMTP id S1161134AbWGJNKd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Jul 2006 09:10:33 -0400
To: Marcus Better <marcus@better.se>
In-Reply-To: <44B24FF6.5060102@better.se>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcus Better wrote:

>Thomas Hellstr=F6m wrote:
> =20
>
>>Does the "noirqdebug" option fix the problem?
>>   =20
>>
>
>Yes... but it breaks switching to a text console. I get an interesting
>"fluid" effect on the screen (a bright static pattern), and the keyboa=
rd
>locks up.
>
>Marcus
>
> =20
>
Hi!
Are you _sure_ these are related?
If you don't use the noirqdebug option, do you have the same problem?

/Thomas

