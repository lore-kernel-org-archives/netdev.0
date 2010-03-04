From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [PATCH V2 2/7] tcp: use limited socket backlog
Date: Thu, 04 Mar 2010 15:56:30 +0100
Message-ID: <1267714590.3302.1.camel@edumazet-laptop>
References: <1267605389-7369-1-git-send-email-yi.zhu@intel.com>
	 <1267605389-7369-2-git-send-email-yi.zhu@intel.com>
	 <1267606433.2997.4.camel@edumazet-laptop>
	 <1267607162.2370.169.camel@debian>
	 <1267610843.2997.7.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6999@shzsmsx502.ccr.corp.intel.com>
	 <1267626678.2997.25.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6BAE@shzsmsx502.ccr.corp.intel.com>
	 <1267682431.2943.10.camel@edumazet-laptop>
	 <DA586906BA1FFC4384FCFD6429ECE860A45A6D9E@shzsmsx502.ccr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	Patrick McHardy <kaber@trash.net>
To: "Zhu, Yi" <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:41052 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab0CDO4g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 09:56:36 -0500
Received: by bwz1 with SMTP id 1so439441bwz.21
        for <netdev@vger.kernel.org>; Thu, 04 Mar 2010 06:56:34 -0800 (PST)
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860A45A6D9E@shzsmsx502.ccr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 04 mars 2010 =C3=A0 19:04 +0800, Zhu, Yi a =C3=A9crit :

>=20
> Since neither sk_drops nor the new MIB value are used by TCP currentl=
y.
> How about I keep the tcp backlog limit patch as is and you implement
> the above in another patch?

Sure, I will do that


