From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 0/5] ipv6: clean up locking in anycast and mcast
Date: Wed, 10 Sep 2014 16:54:07 -0700
Message-ID: <CAM_iQpWX0vkjGJWwhtfGr8KCJ15AVREWttSxvcFQrfzRzAWfYA@mail.gmail.com>
References: <1410306738-18036-1-git-send-email-xiyou.wangcong@gmail.com>
	<20140910.130150.1203685634918422464.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:33144 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752032AbaIJXyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2014 19:54:08 -0400
Received: by mail-oa0-f46.google.com with SMTP id eb12so4602035oac.19
        for <netdev@vger.kernel.org>; Wed, 10 Sep 2014 16:54:07 -0700 (PDT)
In-Reply-To: <20140910.130150.1203685634918422464.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 10, 2014 at 1:01 PM, David Miller <davem@davemloft.net> wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> Date: Tue,  9 Sep 2014 16:52:13 -0700
>
>> This patchset cleans up the locking in anycast.c and mcast.c.
>>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> Please update this based upon the feedback you've received.
>

Sure thing, done.
