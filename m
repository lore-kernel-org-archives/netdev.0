From: Li RongQing <roy.qing.li@gmail.com>
Subject: Re: ICMPv6 too big Packet will makes the network unreachable
Date: Wed, 14 Oct 2015 14:44:56 +0800
Message-ID: <CAJFZqHzECmw=RYa7p3kcc=VAbTYf1ZrBPj+X=atnxn2HsChdCQ@mail.gmail.com>
References: <CAJFZqHz93RmSp369W508i8zbDmxhohG9n4UfxG1TnSxDPD4B=g@mail.gmail.com>
	<1444746394.1871555.408986697.6F3FA822@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:36432 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751551AbbJNGo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 02:44:57 -0400
Received: by qkht68 with SMTP id t68so18601119qkh.3
        for <netdev@vger.kernel.org>; Tue, 13 Oct 2015 23:44:56 -0700 (PDT)
In-Reply-To: <1444746394.1871555.408986697.6F3FA822@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 13, 2015 at 10:26 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
>>    root@du1:~# ip route get 2001:1b70:82a8:18:650:65:0:2
>>    2001:1b70:82a8:18:650:65:0:2 dev eth10.650  src
>> 2001:1b70:82a8:18:650:65:0:2  metric 0
>>        cache
>>    root@du1:~#
>
> Which kernel version did you test this on?
>
> Thanks,
> Hannes


I think it is all version

-Roy
