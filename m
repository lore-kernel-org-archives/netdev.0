From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] selinux: fix random read in
 selinux_ip_postroute_compat()
Date: Fri, 06 Nov 2015 06:46:07 -0800
Message-ID: <1446821167.4184.66.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CACT4Y+ZVnfoqeJZ5cOKu70d3N9LuPMeotarKGBx-EHwYrOe-Eg@mail.gmail.com>
	 <1446752806.4184.50.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1446759564.4184.65.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151105.164613.618044250901993825.davem@davemloft.net>
	 <CACT4Y+ZsiydE4BL_6pGS=LcmS19Dr0+HoJ19AY-4UNNxm3eNXA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Paul Moore <paul@paul-moore.com>
To: Dmitry Vyukov <dvyukov@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35294 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161411AbbKFOqJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Nov 2015 09:46:09 -0500
Received: by pasz6 with SMTP id z6so129071466pas.2
        for <netdev@vger.kernel.org>; Fri, 06 Nov 2015 06:46:09 -0800 (PST)
In-Reply-To: <CACT4Y+ZsiydE4BL_6pGS=LcmS19Dr0+HoJ19AY-4UNNxm3eNXA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-11-06 at 14:52 +0100, Dmitry Vyukov wrote:

> Fixed the issue for me.

Thanks Dmitry

I'll submit ~6 additional patches, after doing a long due audit.
