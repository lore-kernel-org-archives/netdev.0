From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] atl1c: dont use highprio tx queue
Date: Thu, 16 Feb 2012 14:12:33 +0100
Message-ID: <1329397953.9395.0.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1329063403.1449.14.camel@localhost.localdomain>
	 <CA+5PVA52+0vOMF6+tvMPkgzhdTKJRQnrjD4FfVmBZs0TMDJ5cg@mail.gmail.com>
	 <1329204997.24837.15.camel@edumazet-laptop>
	 <1329366846.5646.1.camel@edumazet-laptop>
	 <C6B7BB6C-D1B8-4454-A2B2-558FCA5B0BBD@m3y3r.de>
	 <1329373082.5646.9.camel@edumazet-laptop>
	 <21390AB8-BD9B-44D7-B2CE-B20AF7605CE7@m3y3r.de>
	 <1329374591.5646.23.camel@edumazet-laptop>
	 <CA+5PVA74bejZhPxUAFHaeHLB0NBd7PCRc1sQvmSY7QdmarCWEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Thomas Meyer <thomas@m3y3r.de>, David Miller <davem@davemloft.net>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"jcliburn@gmail.com" <jcliburn@gmail.com>,
	"chris.snook@gmail.com" <chris.snook@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Josh Boyer <jwboyer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:65530 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750906Ab2BPNMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Feb 2012 08:12:38 -0500
In-Reply-To: <CA+5PVA74bejZhPxUAFHaeHLB0NBd7PCRc1sQvmSY7QdmarCWEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 16 f=C3=A9vrier 2012 =C3=A0 07:36 -0500, Josh Boyer a =C3=A9cr=
it :

> As I think David handles netdev patches a bit differently for stable =
releases,
> I'd like to suggest this get included in the next batch for the 3.2 k=
ernel.
> We've been seeing the bug this patch fixes in Fedora for quite a whil=
e now.

Hard to believe this bug lasted so long...
