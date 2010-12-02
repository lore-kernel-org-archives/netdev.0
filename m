From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Thu, 02 Dec 2010 15:04:38 +0100
Message-ID: <1291298678.2871.66.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>
	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>
	 <1288100208.3169.112.camel@edumazet-laptop>  <4CC6DD69.4020502@cox.net>
	 <1288103614.2622.0.camel@edumazet-laptop>  <4CC89333.1040407@cox.net>
	 <1288213502.2658.52.camel@edumazet-laptop>  <4CF7A0DE.2050706@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:36235 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757591Ab0LBOEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Dec 2010 09:04:42 -0500
Received: by wwa36 with SMTP id 36so8762339wwa.1
        for <netdev@vger.kernel.org>; Thu, 02 Dec 2010 06:04:41 -0800 (PST)
In-Reply-To: <4CF7A0DE.2050706@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 02 d=C3=A9cembre 2010 =C3=A0 08:36 -0500, Joe Buehler a =C3=A9=
crit :
> We have had no further problems with crashes.  The SMP memory barrier
> fixes seem to have been the final piece that was missing.
>=20
> Thanks for all the help, you guys are great.
>=20
> Joe Buehler
>=20

Great, thanks for your feedback Joe !


