From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fwd: r8169 - Serios Regression (was Re: r8169 linux driver)
Date: Mon, 11 Jan 2010 01:01:15 +0100
Message-ID: <20100111000115.GB8959@electric-eye.fr.zoreil.com>
References: <a16d8c9b1001101351y1783157r327761bd2c86def1@mail.gmail.com>
 <a16d8c9b1001101355x72565562k7c16e5acca243fe4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Vlad Dascalu <vlad.dascalu@goobix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 49.119.116-78.rev.gaoland.net ([78.116.119.49]:44320 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751424Ab0AKABX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Jan 2010 19:01:23 -0500
Content-Disposition: inline
In-Reply-To: <a16d8c9b1001101355x72565562k7c16e5acca243fe4@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 10, 2010 at 10:55:23PM +0100, Vlad Dascalu wrote:
[...]
> There are lots of reports and stack dumps at
> https://bugzilla.redhat.com/show_bug.cgi?id=538920.

Mmmm... Mixing different network cards.

> It seems it's mainly a communication issue to get those dumps on
> lkml where people can look at it.

I'll take a look tomorrow. A complete dmesg from boot to bug would be
welcome.

-- 
Ueimor
