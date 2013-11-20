From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG,REGRESSION?] 3.11.6+,3.12: GbE iface rate drops to few KB/s
Date: Wed, 20 Nov 2013 10:21:24 -0800
Message-ID: <1384971684.10637.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20131112083633.GB10318@1wt.eu> <87a9hagex1.fsf@natisbad.org>
	 <20131112100126.GB23981@1wt.eu> <87vbzxd473.fsf@natisbad.org>
	 <20131113072257.GB10591@1wt.eu> <20131117141940.GA18569@1wt.eu>
	 <1384710098.8604.58.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131120171227.GG8581@1wt.eu> <20131120173436.GK8581@1wt.eu>
	 <1384969222.10637.20.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20131120181532.GM8581@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, Arnaud Ebalard <arno@natisbad.org>,
	edumazet@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	linux-arm-kernel@lists.infradead.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:61617 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753716Ab3KTSVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Nov 2013 13:21:25 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so5633240pdj.17
        for <netdev@vger.kernel.org>; Wed, 20 Nov 2013 10:21:25 -0800 (PST)
In-Reply-To: <20131120181532.GM8581@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-20 at 19:15 +0100, Willy Tarreau wrote:

> No, I was on latest stable (3.10.19) which exhibits the regression but does
> not yet have your fix above. Then I tested the patch your proposed in this
> thread, then this latest one. Since the patch is not yet even in Linus'
> tree, I'm not sure Arnaud has tried it yet.

Oh right ;)

BTW Linus tree has the fix, I just checked this now.

(Linus got David changes 19 hours ago)
