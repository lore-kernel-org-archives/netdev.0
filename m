From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] r8169: fix a bug in rtl8169_init_phy()
Date: Sat, 19 Mar 2011 20:41:02 +0100
Message-ID: <20110319194102.GA15060@electric-eye.fr.zoreil.com>
References: <4D84A46B.1000407@example.com> <1300548821.2831.28.camel@edumazet-laptop> <1300549151.2831.32.camel@edumazet-laptop> <201103191641.41718.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Anca Emanuel <anca.emanuel@gmail.com>, piotr@hosowicz.com,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Hayes <hayeswang@realtek.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35179 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757094Ab1CSTqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Mar 2011 15:46:50 -0400
Content-Disposition: inline
In-Reply-To: <201103191641.41718.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hayes Cced.

Oliver Neukum <oliver@neukum.org> :
[wrong operator priority fixed by Eric]
> Thank you. I feel like banging my head against something.

Spare your walls : I added the test and I was quite satisfied
after testing ... with an always gigabit capable peer :o/

-- 
Ueimor
