From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169: remove the obsolete and incorrect AMD workaround
Date: Wed, 23 Jan 2013 01:05:41 +0100
Message-ID: <20130123000541.GA9515@electric-eye.fr.zoreil.com>
References: <20130121234205.GA12449@electric-eye.fr.zoreil.com> <1358843435-24719-1-git-send-email-timo.teras@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?utf-8?B?VGVyw6Rz?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32774 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713Ab3AWAew (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 19:34:52 -0500
Content-Disposition: inline
In-Reply-To: <1358843435-24719-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=C3=A4s <timo.teras@iki.fi> :
[...]

Acked-by: Francois Romieu <romieu@fr.zoreil.com>

desc->opts2 is now a bit different in the RxRes path - the only path
where the patch can be noticed. I hope it won't uncloak something else.

--=20
Ueimor
