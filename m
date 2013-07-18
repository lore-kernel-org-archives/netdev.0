From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/core/dst.c:274 dst_release+0x2d/0x56()
Date: Thu, 18 Jul 2013 09:37:19 -0700
Message-ID: <1374165439.6097.40.camel@edumazet-glaptop>
References: <CADCFf2jAJRiHgMaMs8tNWSaonPmXg6q5C66iisdpuz9yMSAV+w@mail.gmail.com>
	 <1372799622.4979.22.camel@edumazet-glaptop>
	 <CADCFf2hEzwgtqfn4nHc4VwgT2+_XW9=uAos7Qo5YsEpRCWFO5Q@mail.gmail.com>
	 <CADCFf2iUeyhnfhHET2Tbi1bM+7h=2LXLFvcerXHsz3Xv6E6zLw@mail.gmail.com>
	 <1372950494.4979.97.camel@edumazet-glaptop>
	 <CADCFf2gS=m_X2WOVGdgUoKyGgdn1sD9HsBYhjikeMN05RExrOQ@mail.gmail.com>
	 <CADCFf2jzs+41uKD9RjotXpqSRDoJnSFY90LVKt2UeQfUF05Wrg@mail.gmail.com>
	 <1374083689.6097.19.camel@edumazet-glaptop>
	 <CADCFf2gS3sS0hL1pr-P+LUVqhvBEMLy-Q8hRp-R8c06e4qtp2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Fernando Soto <fernando.soto@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f175.google.com ([209.85.214.175]:61648 "EHLO
	mail-ob0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752128Ab3GRQhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jul 2013 12:37:23 -0400
Received: by mail-ob0-f175.google.com with SMTP id xn12so3903777obc.6
        for <netdev@vger.kernel.org>; Thu, 18 Jul 2013 09:37:22 -0700 (PDT)
In-Reply-To: <CADCFf2gS3sS0hL1pr-P+LUVqhvBEMLy-Q8hRp-R8c06e4qtp2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-18 at 11:55 -0400, Fernando Soto wrote:
> Hi Eric,
> 
> I applied the patch to the latest 3.10.1 and the network is working
> fine. I'm not sure if it is due to the patch or any other changes
> between 3.10.0 and 3.10.1.
> I'll leave iperf running for a few days. Looks good so far.
> 
> Thank you!

Thanks for the update !
