From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 6/7] net_sched: cls: move allocation in ->init to
 generic layer
Date: Tue, 14 Jan 2014 10:57:16 -0800
Message-ID: <CAM_iQpWrF5HHttDr5g7k0d9eJibZEFOAc60gOM7bHX4+jwQjuA@mail.gmail.com>
References: <1389312845-10304-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389312845-10304-7-git-send-email-xiyou.wangcong@gmail.com>
	<20140113.114923.2164522715863402981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:49511 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751587AbaANS5R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 13:57:17 -0500
Received: by mail-ob0-f169.google.com with SMTP id wp4so22946obc.14
        for <netdev@vger.kernel.org>; Tue, 14 Jan 2014 10:57:17 -0800 (PST)
In-Reply-To: <20140113.114923.2164522715863402981.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 13, 2014 at 11:49 AM, David Miller <davem@davemloft.net> wrote:
>
> What I'm going to do for now is apply patches 1-5 and 7.
>

Sounds good to me. I will re-work on it.
Thanks!
