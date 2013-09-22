From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Xen-devel] TSQ accounting skb->truesize degrades throughput for
 large packets
Date: Sun, 22 Sep 2013 10:36:40 +0800
Message-ID: <CAM_iQpUCGA+ifOUoyh4EuPz5sn8wUgtoD=_5dpRMuYV5aqEdxQ@mail.gmail.com>
References: <20130906101635.GI14104@zion.uk.xensource.com>
	<1378472268.31445.15.camel@edumazet-glaptop>
	<522A049A.7000105@citrix.com>
	<1378486840.31445.36.camel@edumazet-glaptop>
	<1378574494.26319.14.camel@edumazet-glaptop>
	<522E4080.2050802@citrix.com>
	<1378763815.26319.39.camel@edumazet-glaptop>
	<loom.20130921T045654-573@post.gmane.org>
	<20130921150327.GA9078@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: xen-devel@lists.xensource.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:46785 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752557Ab3IVCgk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Sep 2013 22:36:40 -0400
Received: by mail-ob0-f176.google.com with SMTP id uy5so2336276obc.35
        for <netdev@vger.kernel.org>; Sat, 21 Sep 2013 19:36:40 -0700 (PDT)
In-Reply-To: <20130921150327.GA9078@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 21, 2013 at 11:03 PM, Wei Liu <wei.liu2@citrix.com> wrote:
> On Sat, Sep 21, 2013 at 03:00:26AM +0000, Cong Wang wrote:
>> Eric Dumazet <eric.dumazet <at> gmail.com> writes:
>>
>> >
>> > Yeah, my own test was more like the following
>> >
>> ...
>> >
>> > Note that it also seems to make Hystart happier.
>> >
>> > I will send patches when all tests are green.
>> >
>>
>> How is this going? I don't see any patch posted to netdev.
>>
>
> I'm afraid you forgot to CC any relevant people in thie email. :-)
>

I was replying via newsgroup, not mailing list. :)

Anyway, adding Eric and netdev now.
