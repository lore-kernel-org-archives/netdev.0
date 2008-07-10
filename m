From: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>
Subject: Re: Detecting TCP loss on the receiving side?
Date: Thu, 10 Jul 2008 16:19:14 -0400
Message-ID: <48766EC2.2090000@limebrokerage.com>
References: <4876668C.8040108@limebrokerage.com> <48766CF0.1020101@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>,
	netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.limebrokerage.com ([64.111.220.126]:55817 "EHLO
	infra1-jc.limebrokerage.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757694AbYGJUTQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jul 2008 16:19:16 -0400
In-Reply-To: <48766CF0.1020101@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
> If this is just for troubleshooting, why not just take a tcpdump trac=
e?

We're pushing a lot of data.. several Mbps pretty much all day long..=20
and the (suspected) loss occurs sporadically.  Ideally we'd like to be=20
able to easily correlate it with latency seen in our app.

Cheers,
Dan

--=20
Dan No=E9
Software Engineer
Lime Brokerage LLC
781-370-2518
