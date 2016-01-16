From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH, RESEND] ssb: mark ssb_bus_register as __maybe_unused
Date: Sat, 16 Jan 2016 14:10:31 +0200
Message-ID: <87bn8l7miw.fsf@kamboji.qca.qualcomm.com>
References: <8128014.DbbgBtKY3z@wuerfel>
	<8760ywd5fe.fsf@kamboji.qca.qualcomm.com> <4037550.DMaVTE01Aq@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-arm-kernel@lists.infradead.org, linux-mips@linux-mips.org,
	Hauke Mehrtens <hauke@hauke-m.de>,
	=?utf-8?Q?Rafa=C5=82_Mi=C5=82ecki?= <zajec5@gmail.com>,
	linux-kernel@vger.kernel.org, Michael Buesch <m@bues.ch>,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:56926 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826AbcAPMKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Jan 2016 07:10:40 -0500
In-Reply-To: <4037550.DMaVTE01Aq@wuerfel> (Arnd Bergmann's message of "Fri, 15
	Jan 2016 00:13 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arnd Bergmann <arnd@arndb.de> writes:

> On Thursday 14 January 2016 08:46:29 Kalle Valo wrote:
>> I can take it. For historical reasons ssb patches go through my
>> wireless-drivers trees.
>
> I found this in my backlog, and I believe it still applies. Can you take
> that one too?

I'm not sure what you mean here, I can take any ssb patch if it's ok for
Michael or Rafal :)

Just please submit the patch properly (with S-o-B line) and CC
linux-wireless so that it goes to patchwork.

-- 
Kalle Valo
