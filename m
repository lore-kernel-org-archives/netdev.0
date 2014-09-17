From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH] net: sched: cls_u32: rcu can not be last node
Date: Wed, 17 Sep 2014 09:40:33 -0700
Message-ID: <CAM_iQpW1AOgKqQXwh2BNMH_GypTVX6NgyQJZ7Mby0kABjbBu4w@mail.gmail.com>
References: <20140917053434.2833.66129.stgit@nitbit.x32>
	<541921FD.1090203@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f43.google.com ([209.85.219.43]:39617 "EHLO
	mail-oa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755682AbaIQQke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 12:40:34 -0400
Received: by mail-oa0-f43.google.com with SMTP id m19so692336oag.16
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 09:40:33 -0700 (PDT)
In-Reply-To: <541921FD.1090203@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 16, 2014 at 10:54 PM, Oliver Hartkopp
<socketcan@hartkopp.net> wrote:
> Please add an appropriate comment to the *code* to prevent this knowledge to
> disappear. No one will search/find this in git commit messages next time.
>

+1

Even though I dig git log, I agree adding a one-line comment is better.
