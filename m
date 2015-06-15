From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: displayed name changed in ip link show for bridge- and other
 interfaces
Date: Mon, 15 Jun 2015 09:23:53 +0200
Message-ID: <557E7D89.30301@6wind.com>
References: <201506141200.20435.ulrich.gemkow@ikr.uni-stuttgart.de> <557DCD0A.5040500@hartkopp.net> <557DD20E.4080005@hartkopp.net>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Ulrich Gemkow <ulrich.gemkow@ikr.uni-stuttgart.de>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:34496 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751515AbbFOHX4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 03:23:56 -0400
Received: by wgv5 with SMTP id 5so61176752wgv.1
        for <netdev@vger.kernel.org>; Mon, 15 Jun 2015 00:23:55 -0700 (PDT)
In-Reply-To: <557DD20E.4080005@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/06/2015 21:12, Oliver Hartkopp a =E9crit :
> @Nicolas: Just saw that you were not responsible for the @NONE m)
>
> Sorry.
>
> Btw. do you know why this @NONE stuff just emerged in 4.1-rc ?
Yes, it comes from the iflink cleanup in kernel:
http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/n=
et/core/dev.c?id=3De1622baf54df8cc958bf29d71de5ad545ea7d93c


Regards,
Nicolas
