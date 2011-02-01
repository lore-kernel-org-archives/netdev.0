From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6 configurable default value for the privacy extension
 flag
Date: Tue, 01 Feb 2011 13:04:37 +0900
Message-ID: <4D478655.6040706@linux-ipv6.org>
References: <20110131164945.3370cbcd@baileys.at.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?SnVsaWVuIEF1YsOp?= <jul.aube@gmail.com>,
	netdev@vger.kernel.org, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: j.aube@laposte.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:36874 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751789Ab1BAEO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jan 2011 23:14:57 -0500
In-Reply-To: <20110131164945.3370cbcd@baileys.at.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

(2011/02/01 0:49), Julien Aub=C3=A9 wrote:

>+	} else {
>+		printk(KERN_WARNING "IPv6 Privacy Extension "
>+	"is disabled by default (invalid value %d)\n", ipv6_default_privacy)=
;
>+	}

I think WARNING is too high.

--yoshfuji
