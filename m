From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: sky2 still badly broken
Date: Thu, 03 May 2012 21:36:50 +0200
Message-ID: <4FA2DE52.306@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net> <4FA14EC6.6050207@linuxsystems.it> <20120502115618.04ab8ff9@s6510.linuxnetplumber.net> <4FA2527A.6020808@linuxsystems.it> <20120503082352.771acab3@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:47628 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755470Ab2ECTfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 15:35:41 -0400
In-Reply-To: <20120503082352.771acab3@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 03/05/2012 17:23, Stephen Hemminger ha scritto:
> The receiver on some versions of the chip can't keep up with full spe=
ed
> of 1G bit/sec. The receive  FIFO has hardware issues, and since I don=
't
> work for Marvell, working around the problem is guesswork.

Just one question: if that is true why don't I have any problem with a=20
point to point gigabit link? I did transfer 3GB from ram to ram (ramfs)=
=20
at 100+MB/s without any issue in a point to point setup, as soon as I=20
attach it to the switch I have problems (very low transfer rate and ton=
s=20
of rx errors).

Niccol=F2
