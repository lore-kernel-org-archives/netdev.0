From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] net: use for_each_netdev_safe() in rtnl_group_changelink()
Date: Tue, 24 Mar 2015 09:46:32 -0700
Message-ID: <CAM_iQpWCe-YFLuGo9YvwWmB1anG+ttv-jZ-5kEYotLrmySKErw@mail.gmail.com>
References: <1427153469-32542-1-git-send-email-xiyou.wangcong@gmail.com>
	<1427157352.25985.86.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33643 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752779AbbCXQqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 12:46:33 -0400
Received: by pabxg6 with SMTP id xg6so218258130pab.0
        for <netdev@vger.kernel.org>; Tue, 24 Mar 2015 09:46:32 -0700 (PDT)
In-Reply-To: <1427157352.25985.86.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 23, 2015 at 5:35 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> It seems this bug was added in commit e7ed828f10bd8, right ?
>
> Fixes: e7ed828f10bd8 ("netlink: support setting devgroup parameters")
>

Right.

I hope Dave or patchwork can add it into changelog.

Thanks.
