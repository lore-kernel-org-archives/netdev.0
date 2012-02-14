From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: Re: Re: Re: limited network bandwidth with 3.2.x kernels
Date: Tue, 14 Feb 2012 17:00:10 +0100
Message-ID: <1329235210.4818.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <8633039.fHPLx6GNq3@localhost.localdomain>
	 <1920135.kl3o7Tt79c@localhost.localdomain>
	 <1329228798.4818.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <5133914.uYLb0gnNTc@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: alekcejk@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:56441 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750887Ab2BNQAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Feb 2012 11:00:15 -0500
Received: by lagu2 with SMTP id u2so102563lag.19
        for <netdev@vger.kernel.org>; Tue, 14 Feb 2012 08:00:14 -0800 (PST)
In-Reply-To: <5133914.uYLb0gnNTc@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 14 f=C3=A9vrier 2012 =C3=A0 16:28 +0200, alekcejk@googlemail.c=
om a
=C3=A9crit :

> Yes, results are the same for 3.2.3 kernel with and without running
> this command and for geographically close to me server (speed not lim=
ited)
> and for server not close to me speed limitation the same.

I wonder if "netstat -s" is telling the truth ...

Could you post after a transfert on 3.2, "grep TcpExt /proc/net/netstat=
"
