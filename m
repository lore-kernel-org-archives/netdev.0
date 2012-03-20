From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x1f2/0x200()
Date: Wed, 21 Mar 2012 00:27:00 +0100
Message-ID: <20120320232700.GA21932@electric-eye.fr.zoreil.com>
References: <20120205134050.7e135bb231b613806a2e0b70@gmail.com> <4F2F0065.9040909@lwfinger.net> <20120205222141.GA26223@electric-eye.fr.zoreil.com> <20120205145913.194746473361e324bda1eb4a@gmail.com> <CAKFRV=NghW3kokuD-VBAzVJf09r-9ePMG+L7qDYfqmuHwWo4mg@mail.gmail.com> <20120320093709.GA5058@electric-eye.fr.zoreil.com> <4F689131.2030607@gmail.com> <4F68F727.9030405@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:35667 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1759517Ab2CTX3C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Mar 2012 19:29:02 -0400
Content-Disposition: inline
In-Reply-To: <4F68F727.9030405@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Justin P. Mattock <justinmattock@gmail.com> :
[...]
> well i dont know what happened.. I suspend throughout the day
> without any issues, but then on one wakeup everything went to crap
> ethernet started to try and connect without any wires in.. only
> thing I can think of is I was dongling with my phone(but the phone
> was disconnected before suspend),which uses a different module..

The MII registers read as 0xff. I'll have to figure why the
suspend / resume cycle failed, or why it seemed to work. :o/

-- 
Ueimor
