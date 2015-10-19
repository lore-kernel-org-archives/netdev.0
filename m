From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 3/4] sch_htb: update backlog as well
Date: Mon, 19 Oct 2015 13:46:45 -0700
Message-ID: <CAM_iQpWQ4pY2i=NJqwqZT8NeS5V0GdRiY+n1cJRnUyXnwZhkYw@mail.gmail.com>
References: <1444675083-9825-1-git-send-email-xiyou.wangcong@gmail.com>
	<1444675083-9825-4-git-send-email-xiyou.wangcong@gmail.com>
	<561E499D.7060402@mojatatu.com>
	<CAM_iQpXsweCm+ETtHeNQFMoEJ7jGGSONG=MD6KX=+GHuBFvq2w@mail.gmail.com>
	<5620EB64.4010209@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Cong Wang <cwang@twopensource.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:35666 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753434AbbJSUqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2015 16:46:46 -0400
Received: by obbzf10 with SMTP id zf10so149499721obb.2
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2015 13:46:46 -0700 (PDT)
In-Reply-To: <5620EB64.4010209@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 16, 2015 at 5:19 AM, Jamal Hadi Salim <jhs@mojatatu.com> wrote:
>
> Like i said earlier, the idea of keeping track of backlog is useful.
> I think the commit log threw me off.
> "It is odd to see qlen!=0 but backlog==0"
> If you change that commit log then:

Sure, I think DaveM probably already discards this version, I will
update the changelog as you pointed out and resend.

>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>
>

Thanks!
