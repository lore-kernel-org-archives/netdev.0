From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 11 Jun 2012 23:52:03 +0200
Message-ID: <20120611215203.GA8860@electric-eye.fr.zoreil.com>
References: <20120501182405.3dda59b9@stein> <20120501172748.GA17117@electric-eye.fr.zoreil.com> <20120501200423.6804dcf0@stein> <20120501200403.GA20763@electric-eye.fr.zoreil.com> <20120503204813.65468df7@stein> <20120602111335.0b94fb59@stein> <loom.20120611T175322-643@post.gmane.org> <20120611204925.GA7070@electric-eye.fr.zoreil.com> <CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tomas Papan <tomas.papan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53481 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752509Ab2FKWB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 18:01:26 -0400
Content-Disposition: inline
In-Reply-To: <CAMGsXDRjqsgL=KCR=dQGTNhBS7G-AK-VtDEVT+8bUUqFUR5HsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomas Papan <tomas.papan@gmail.com> :
[...]
> If you need something else just tell me.

The XID line should look something like :

[    8.925786] r8169 0000:03:00.0: eth0: RTL8168evl/8111evl at 0xffffc900050ec000, 00:e0:4c:68:00:1f, XID 0c900800 IRQ 51

(whence the 'XID' thing)

Please send a _complete_ dmesg. I won't bet it will solve anything but
it can't be more useless than the generic watchdog message.

Thanks.

-- 
Ueimor
