From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/13] net_sched: misc cleanups and improvements
Date: Tue, 04 Nov 2014 17:47:48 -0800
Message-ID: <1415152068.1458.2.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1415125250.25370.2.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_iQpXZBz=Ha2h3mCwnZKa3Etx7Ya9NxAWe_p8T+VjRUs5g0g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f177.google.com ([209.85.213.177]:60201 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751867AbaKEBrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 20:47:55 -0500
Received: by mail-ig0-f177.google.com with SMTP id hl2so539541igb.10
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 17:47:55 -0800 (PST)
In-Reply-To: <CAM_iQpXZBz=Ha2h3mCwnZKa3Etx7Ya9NxAWe_p8T+VjRUs5g0g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2014-11-04 at 17:25 -0800, Cong Wang wrote:

> Seriously, think about why it should when it's just cleanup's, be practical.

I seriously ask you to not do cleanups then.

Some people are working adding real stuff here, this code changing every
month is slowing them a lot.
