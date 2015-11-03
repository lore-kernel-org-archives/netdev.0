From: Loganaden Velvindron <loganaden@gmail.com>
Subject: Re: nothing other than BUG fixes please
Date: Tue, 3 Nov 2015 15:25:25 +0000
Message-ID: <CAOp4FwREJmD3+FWDmoXps-4ZrTxyVk0LBYJ7E77yOjPswjWjvw@mail.gmail.com>
References: <20151102.231014.1768364387900448838.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:34519 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932186AbbKCPZ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 10:25:26 -0500
Received: by padhx2 with SMTP id hx2so13421897pad.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 07:25:26 -0800 (PST)
In-Reply-To: <20151102.231014.1768364387900448838.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 4:10 AM, David Miller <davem@davemloft.net> wrote:
>
>
> If it's not a bug fix, I really don't want to see it submitted at
> this time.  No exceptions.
>
> Things will stay this way until some short period after the merge
> window opens and I open up net-next and patchwork to new feature
> patches and cleanups.
>
> Anyone violating this will not even get an email reply from me,
> I will simply toss your submission from patchwork silently.  It's
> simply too much pointless work for me to keep reminding people
> what I explicitly state on the list about the state of the trees
> we develop under.
>
> The best part is this will only punish the people who don't pay
> attention and just blindly come post patches here when it's convenient
> for them to submit patches, rather than actually reading the list and
> making an effort to participate in development properly.


Do small "security" patches that prevent resource leakage count as bugfixes ?

e.g:
http://patchwork.ozlabs.org/patch/537519/


>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
