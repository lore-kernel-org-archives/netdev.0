From: Cong Wang <cwang@twopensource.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 4 May 2015 15:17:12 -0700
Message-ID: <CAHA+R7OrtnPuNX+qa_o4MArL2Sc8T9jALp5tyQYFMv4dxUeF7A@mail.gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	<20150504133943.GA17043@x131e>
	<CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	<1430772572.27254.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7OD7Bh52MkB1hKs8DdncrgBN2_1VYQwrFGetJFJ7chgyg@mail.gmail.com>
	<1430777167.27254.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35283 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750965AbbEDWRO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 18:17:14 -0400
Received: by widdi4 with SMTP id di4so137924768wid.0
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 15:17:12 -0700 (PDT)
In-Reply-To: <1430777167.27254.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 4, 2015 at 3:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-05-04 at 14:38 -0700, Cong Wang wrote:
>
>> Compile-test only patch is never ready for review, I thought it is too obvious
>> to mention.
>
> Thats not relevant.
>
> Obvious or not, you are not making things easy for reviewers.
>

Why should I make a NOT-ready-for-review patch easy for reviewers?
What's the point here? I don't have the right to choose my patch NOT
to be reviewed? Huh...


> Our time is precious too, even if you believe its a minor detail.
>
> If you don't care for our feedback, send private patches.


Not until it is ready, apparently.


>
> When I hit 'Reply' to your mail, I don't have the patch available at
> hand, and need to copy/paste it.

That is EXACTLY what I want, because it is NOT READY FOR REVIEW.


>
> Surely I am not alone.
>
> Surely you can change the way you provide patches, even if they are in
> RFC state.

If every patch in this mailing list has to be ready, yes.

Otherwise no, sometimes we do need a patch (or a diff if it is a better name)
ONLY for discussion, aka, NOT for review.


>
> If you don't have time, just ignore these bug reports, and do whatever
> you need to, nobody will complain.
>

Apparently you did nothing before I just sent a reply without a patch,
only patch draws your attention for some reason, I _guess_ you only
rush for patches.
