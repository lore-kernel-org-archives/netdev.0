From: Cong Wang <cwang@twopensource.com>
Subject: Re: [patch net-next] sched: fix act file names in header comment
Date: Wed, 5 Nov 2014 13:38:51 -0800
Message-ID: <CAHA+R7N-gbLLc1BOeL9a7Cxwa6YNkDdBL==2RovWh4K2bWdidw@mail.gmail.com>
References: <1415217111-9803-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f43.google.com ([209.85.192.43]:45494 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751623AbaKEViw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 16:38:52 -0500
Received: by mail-qg0-f43.google.com with SMTP id f51so44593qge.2
        for <netdev@vger.kernel.org>; Wed, 05 Nov 2014 13:38:51 -0800 (PST)
In-Reply-To: <1415217111-9803-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 5, 2014 at 11:51 AM, Jiri Pirko <jiri@resnulli.us> wrote:
> diff --git a/net/sched/act_gact.c b/net/sched/act_gact.c
> index d6bcbd9..7fffc22 100644
> --- a/net/sched/act_gact.c
> +++ b/net/sched/act_gact.c
> @@ -1,5 +1,5 @@
>  /*
> - * net/sched/gact.c    Generic actions
> + * net/sched/act_gact.c                Generic actions

Or maybe just remove the file name from the comment?
I have no strong opinions here.
