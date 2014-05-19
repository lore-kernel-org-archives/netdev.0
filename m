From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: 3.14 tc oops
Date: Mon, 19 May 2014 12:14:26 -0700
Message-ID: <CAM_iQpVseFM9aHhOd-SRFUPtsxjdaAv2cpJ-BwwLotirB9rH_A@mail.gmail.com>
References: <1592838.91HrDxMk9i@comer>
	<3222104.QGqslXqjVx@comer>
	<CAM_iQpVVwE6+SgYKr5kiHhv0yE3-eRynxo5AkPSL5ZQ=aA5aJw@mail.gmail.com>
	<2501516.A9ihW45TvK@comer>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: Kelly Anderson <kelly@xilka.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f53.google.com ([209.85.219.53]:55484 "EHLO
	mail-oa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964803AbaESTO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 May 2014 15:14:27 -0400
Received: by mail-oa0-f53.google.com with SMTP id m1so6604011oag.26
        for <netdev@vger.kernel.org>; Mon, 19 May 2014 12:14:26 -0700 (PDT)
In-Reply-To: <2501516.A9ihW45TvK@comer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 16, 2014 at 8:28 PM, Kelly Anderson <kelly@xilka.com> wrote:
> On Friday, May 16, 2014 17:18:52 Cong Wang wrote:
>> On Mon, Apr 7, 2014 at 1:00 AM, Kelly Anderson <kelly@xilka.com> wrote:
>> > Cong,
>> >
>> > The patch did not fix the problem.
>> >
>> > For your convenience, I've attached tc filter show for eth0 and eth1, as
>> > well as a mangled version of my tcng input file.
>>
>> Sorry that I totally forgot this thread....
>>
>> I just tested a new patch (attached), it works for me, please verify it.
>>
>> Thanks for the report anyway.
>
> Great, the new patch seems to work fine with 3.14.4.  If you haven't done it
> yet, you should probably get that patch pulled into 3.14 stable.
>

OK. I will send a formal patch and I believe David will queue it for
3.14 stable.

Thanks!
