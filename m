From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [3.8-rc] regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Sat, 5 Jan 2013 10:37:18 +0100
Message-ID: <20130105093718.GA938@electric-eye.fr.zoreil.com>
References: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?utf-8?B?SsO2cmc=?= Otte <jrg.otte@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43294 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755338Ab3AEKFA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jan 2013 05:05:00 -0500
Content-Disposition: inline
In-Reply-To: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

J=C3=B6rg Otte <jrg.otte@gmail.com> :
[...]
> It's a regression, it never happend before 3.8-rc.

Please check that 'dmesg | grep XID' exhibits a 8168evl.

I'll showe and dig it. It's epidemic.

--=20
Ueimor
