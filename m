From: Cong Wang <cwang@twopensource.com>
Subject: Re: Suspicious RCU usage in bridge with Linux v4.0-9362-g1fc149933fd4
Date: Mon, 4 May 2015 15:44:16 -0700
Message-ID: <CAHA+R7N0MAKSHROEHQ+aHHD=Vv+trNG=QNttQVG2=MSY__k5pg@mail.gmail.com>
References: <CA+5PVA5gE_pG5iPKBgugsEjLsOYvq9bWKfB+2OeEujjdOb+URg@mail.gmail.com>
	<20150504133943.GA17043@x131e>
	<CAHA+R7PAzzz+CZfnOoweBdeLY8tRkr2bSDEpQgdtEKUeaZbWpQ@mail.gmail.com>
	<1430772572.27254.3.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7OD7Bh52MkB1hKs8DdncrgBN2_1VYQwrFGetJFJ7chgyg@mail.gmail.com>
	<1430777167.27254.8.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAHA+R7OrtnPuNX+qa_o4MArL2Sc8T9jALp5tyQYFMv4dxUeF7A@mail.gmail.com>
	<1430778550.27254.10.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dominick Grift <dac.override@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:34121 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750887AbbEDWoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 18:44:17 -0400
Received: by wgso17 with SMTP id o17so165046925wgs.1
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 15:44:16 -0700 (PDT)
In-Reply-To: <1430778550.27254.10.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 4, 2015 at 3:29 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2015-05-04 at 15:17 -0700, Cong Wang wrote:
>> On Mon, May 4, 2015 at 3:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Mon, 2015-05-04 at 14:38 -0700, Cong Wang wrote:
>> >
>> >> Compile-test only patch is never ready for review, I thought it is too obvious
>> >> to mention.
>> >
>> > Thats not relevant.
>> >
>> > Obvious or not, you are not making things easy for reviewers.
>> >
>>
>> Why should I make a NOT-ready-for-review patch easy for reviewers?
>> What's the point here? I don't have the right to choose my patch NOT
>> to be reviewed? Huh...
>>
>
> Look, I only said :
>
> "Please send inline patches, otherwise its hard for us to review them
> and give feedback."
>
> I gave a quite reasonable request, with a "Please"

With hundreds of patches merged, I don't need to teach how to send
a reviewable patch when it is ready, this one is just not ready for review.

So your request is only valid for patches ready for review. Focus on
the bug.

It is not my first time to get surprised netdev people for some reason
only talk when there is a patch, yet another reason I should send
a patch even just for drawing attentions.
