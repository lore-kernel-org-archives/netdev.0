From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Mon, 11 Jun 2012 22:49:25 +0200
Message-ID: <20120611204925.GA7070@electric-eye.fr.zoreil.com>
References: <20120501182405.3dda59b9@stein> <20120501172748.GA17117@electric-eye.fr.zoreil.com> <20120501200423.6804dcf0@stein> <20120501200403.GA20763@electric-eye.fr.zoreil.com> <20120503204813.65468df7@stein> <20120602111335.0b94fb59@stein> <loom.20120611T175322-643@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Tomas Papan <tomas.papan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53236 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab2FKU6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 16:58:48 -0400
Content-Disposition: inline
In-Reply-To: <loom.20120611T175322-643@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomas Papan <tomas.papan@gmail.com> :
[...]
> I have the same problem on 3.4.1 and 3.4.2 (3.2.x is fine)
> interestingly enough, the problem occurs only once, then it is running fine
> (3.4.1 and six days uptime)

Please send a complete dmesg including the XID line emitted by the
r8169 driver.

-- 
Ueimor
