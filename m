From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: kernel panic in fib_rules_lookup [2.6.27.7 vendor-patched]
Date: Wed, 27 Oct 2010 23:05:02 +0200
Message-ID: <1288213502.2658.52.camel@edumazet-laptop>
References: <loom.20101012T185411-307@post.gmane.org>
	 <1286905245.2703.3.camel@edumazet-laptop>  <4CBF2A3F.2070108@cox.net>
	 <1287612353.2545.11.camel@edumazet-laptop>  <4CC1F47C.9020104@cox.net>
	 <1287805487.2658.5.camel@edumazet-laptop>
	 <1287846669.2658.247.camel@edumazet-laptop>  <4CC30055.5040509@cox.net>
	 <1287851745.2658.364.camel@edumazet-laptop>  <4CC6D7CC.5040608@cox.net>
	 <1288100208.3169.112.camel@edumazet-laptop>  <4CC6DD69.4020502@cox.net>
	 <1288103614.2622.0.camel@edumazet-laptop>  <4CC89333.1040407@cox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:60834 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757274Ab0J0VFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 17:05:07 -0400
Received: by eye27 with SMTP id 27so1124113eye.19
        for <netdev@vger.kernel.org>; Wed, 27 Oct 2010 14:05:05 -0700 (PDT)
In-Reply-To: <4CC89333.1040407@cox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 27 octobre 2010 =C3=A0 17:01 -0400, Joe Buehler a =C3=A9cri=
t :
> Eric, tests with your fixes and with the smp barrier corrections are
> looking positive.  More testing is needed before a final verdict is i=
n
> however -- the load test crashed after 8 hours due to an application =
bug
> that we're working on fixing now.
>=20

Excellent ! Thanks for the report.



