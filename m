From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Subject: Re: [Bugme-new] [Bug 38102] New: BUG kmalloc-2048: Poison overwritten
Date: Thu, 7 Jul 2011 10:32:43 +0400
Message-ID: <CAB9v_DFmXS7_0Sx7VgVzViMSqOTtpaqiKrBABcfARigZabr5fA@mail.gmail.com>
References: <1309882352.2271.19.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705164202.GD2959@hmsreliant.think-freely.org>
	<1309884441.2271.34.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20110705180650.GF2959@hmsreliant.think-freely.org>
	<1309889634.2545.2.camel@edumazet-laptop>
	<1309890775.2545.17.camel@edumazet-laptop>
	<1309891516.2545.23.camel@edumazet-laptop>
	<20110705195353.GG2959@hmsreliant.think-freely.org>
	<1309896147.2545.28.camel@edumazet-laptop>
	<1309896940.2545.34.camel@edumazet-laptop>
	<20110705220644.GB12118@hmsreliant.think-freely.org>
	<20110706173243.404d8599@maggie>
	<1309971379.2292.64.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: =?UTF-8?Q?Michael_B=C3=BCsch?= <m@bues.ch>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	bugme-daemon@bugzilla.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pekka Pietikainen <pp@ee.oulu.fi>,
	Florian Schirmer <jolt@tuxbox.org>,
	Felix Fietkau <nbd@openwrt.org>, Michael Buesch <mb@bu3sch.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:65153 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751826Ab1GGGco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 02:32:44 -0400
Received: by vxb39 with SMTP id 39so474419vxb.19
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2011 23:32:43 -0700 (PDT)
In-Reply-To: <1309971379.2292.64.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry, been busy for the last couple days. Any patches I should test?
