From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: Is this 32-bit NCM?y
Date: Thu, 04 Dec 2014 11:02:19 +0100
Message-ID: <87iohrn36c.fsf@nemi.mork.no>
References: <alpine.LNX.2.03.1411262250160.4356@gmail.com>
	<alpine.LNX.2.03.1412020729470.1351@gmail.com>
	<547D5F84.6020608@audiocodes.com>
	<alpine.LNX.2.03.1412020747360.1921@gmail.com>
	<547D6D7B.5090704@audiocodes.com>
	<E0C3DF2A36210C42B1AB4626A0E10F1FD949424C@aclmbx01.corp.audiocodes.com>
	<547D7243.80508@audiocodes.com>
	<alpine.LNX.2.03.1412021130410.2697@gmail.com>
	<87fvcyqoup.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412021410270.29633@gmail.com>
	<87lhmqp400.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412021453340.7488@gmail.com>
	<1417532733483.89987@audiocodes.com>
	<alpine.LNX.2.03.1412021627360.8131@gmail.com>
	<547EA1D1.8010202@audiocodes.com>
	<alpine.LNX.2.03.1412030659001.1288@gmail.com>
	<547EA82F.5050500@audiocodes.com>
	<alpine.LNX.2.03.1412040730480.1320@gmail.com>
	<548020DD.3030705@audiocodes.com> <874mtbojqo.fsf@nemi.mork.no>
	<alpine.LNX.2.03.1412041052310.3861@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Kevin Zhu <Mingying.Zhu@audiocodes.com>,
	Eli Britstein <Eli.Britstein@audiocodes.com>,
	Alex Strizhevsky <alexxst@gmail.com>,
	Midge Shaojun Tan <ShaojunMidge.Tan@audiocodes.com>,
	"youtux\@gmail.com" <youtux@gmail.com>,
	"linux-usb\@vger.kernel.org" <linux-usb@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:55025 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753284AbaLDKCc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Dec 2014 05:02:32 -0500
In-Reply-To: <alpine.LNX.2.03.1412041052310.3861@gmail.com> (Enrico Mioso's
	message of "Thu, 4 Dec 2014 10:53:49 +0100 (CET)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enrico Mioso <mrkiko.rs@gmail.com> writes:

> Guys!
> Don't forget I can test it - since I have a remote machine with 3.16
> kernel and the device, at least for now.
> So - Bjorn: do I need just to disable padding or do I need also to
> perform some other changes? I am sorry if I ask this a little bit
> stupidly, but I was alittle bit busy here.

I don't know.  I just mentioned it because it is easy to test, although
the method isn't too obvious.  Someone should document this somewhere.
Hey, wait...  Someone did :-)

https://www.kernel.org/doc/Documentation/ABI/testing/sysfs-class-net-cd=
c_ncm


Bj=C3=B8rn
