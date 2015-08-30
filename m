From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH, net-next] r8169: Deny functions membet of array rtl_work
Date: Sun, 30 Aug 2015 10:13:53 +0200
Message-ID: <20150830081353.GA14599@electric-eye.fr.zoreil.com>
References: <1440845029-3079-1-git-send-email-corcodel.marian@gmail.com>
 <20150829112630.GA8873@electric-eye.fr.zoreil.com>
 <CAGg4U=HQwGhQ95+FNumjLOH0m5Bnm8-3kOgfbMUGOV=Lzsyd6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Marian Corcodel <corcodel.marian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:44220 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752378AbbH3IOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2015 04:14:18 -0400
Content-Disposition: inline
In-Reply-To: <CAGg4U=HQwGhQ95+FNumjLOH0m5Bnm8-3kOgfbMUGOV=Lzsyd6A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marian Corcodel <corcodel.marian@gmail.com> :
> Late may add another exceptions . Hard reset is also on close function
> and probe function not need to be present after
> link ok.rtl_reset_work figure like mirror on rtl_open with small exceptions.
> 
> 2015-08-29 14:26 GMT+03:00 Francois Romieu <romieu@fr.zoreil.com>:
[...]
> > Please don't send me private only e-mail.

$ cat >> ~/.procmailrc<<EOD

:0:
* From.*corcodel.marian@gmail.com
/dev/null

EOD

Messages that make their way through mailing-lists will proceed normally.

-- 
Ueimor
