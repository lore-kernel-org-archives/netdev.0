From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 2/3] ARM: include IXP4xx "fuses" support
Date: Mon, 07 May 2007 12:24:46 +0200
Message-ID: <m3k5vlc4nl.fsf@maximus.localdomain>
References: <m3abwhcy74.fsf@maximus.localdomain>
	<m3wszlbiom.fsf@maximus.localdomain>
	<f19298770705062224v5f60535bn7dfce17f4a5e04f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.arm.linux.org.uk,
	Russell King <rmk@arm.linux.org.uk>,
	Jeff Garzik <jeff@garzik.org>,
	lkml <linux-kernel@vger.kernel.org>
To: "Alexey Zaytsev" <alexey.zaytsev@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:59301 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754287AbXEGKYr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2007 06:24:47 -0400
In-Reply-To: <f19298770705062224v5f60535bn7dfce17f4a5e04f@mail.gmail.com> (Alexey Zaytsev's message of "Mon, 7 May 2007 09:24:48 +0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

"Alexey Zaytsev" <alexey.zaytsev@gmail.com> writes:

> #ifndef __ASSEMBLY__
>
>> +static inline u32 ixp4xx_read_fuses(void)

Oops. You're right, of course.
-- 
Krzysztof Halasa
