From: =?ISO-8859-1?Q?Niccol=F2_Belli?= <darkbasic@linuxsystems.it>
Subject: Re: sky2 still badly broken
Date: Tue, 01 May 2012 01:50:03 +0200
Message-ID: <4F9F252B.6060703@linuxsystems.it>
References: <4F9AFE4E.8010108@linuxsystems.it> <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxsystems.it ([2.119.245.41]:35760 "EHLO
	mail.linuxsystems.it" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756704Ab2D3XtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 19:49:04 -0400
In-Reply-To: <20120430122501.5fff4b1e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Il 30/04/2012 21:25, Stephen Hemminger ha scritto:
> You are getting CRC and FIFO overrun errors. What laptop is this?
> Everything works fine on my old Fuijitsu with same chip (but rev 14).
> You could try taking out the status bit checks and see if the
> packets are really okay and the Marvell chip is complaining about
> bogus status.

Laptop is a Samsung X360. I will make a little dump.

Niccol=F2
