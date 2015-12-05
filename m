From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v1 1/6] net: Generalize udp based tunnel offload
Date: Sat, 5 Dec 2015 11:34:47 -0800
Message-ID: <CAKgT0UfQCnz+oGfETZQs-nCP_QL_5qzngB+zC-e6ZN1-kV8C0Q@mail.gmail.com>
References: <566279E5.9070500@gmail.com>
	<20151205.014909.1572453190886968569.davem@davemloft.net>
	<CAKgT0Uc1bJRrzpLUdr3vOFkYZbcqP=J8wgOz1feF+u04aNBg1g@mail.gmail.com>
	<20151205.130313.1952213347830357234.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tom Herbert <tom@herbertland.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	John Linville <linville@tuxdriver.com>,
	Jesse Gross <jesse@kernel.org>,
	Anjali Singhai Jain <anjali.singhai@intel.com>,
	Netdev <netdev@vger.kernel.org>,
	Kiran Patil <kiran.patil@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:34327 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbbLETes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2015 14:34:48 -0500
Received: by ioir85 with SMTP id r85so147315244ioi.1
        for <netdev@vger.kernel.org>; Sat, 05 Dec 2015 11:34:48 -0800 (PST)
In-Reply-To: <20151205.130313.1952213347830357234.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Dec 5, 2015 at 10:03 AM, David Miller <davem@davemloft.net> wrote:
> From: Alexander Duyck <alexander.duyck@gmail.com>
> Date: Sat, 5 Dec 2015 00:24:55 -0800
>
>> Still, hard blocking this isn't necessarily going to push the
>> vendors to change their ways.
>
> Pushing back is different from blocking entirely.

Sorry.  I had the mistaken impression that you were planning to block
this entirely based on earlier comments.

> That means I'm going to be very difficult and make a lot of noise
> until I see the message has seeped in.
>
> It doesn't mean that I won't allow a means to use existing hardware
> offloads.  You'll just have to bear with me, be patient, and survive
> my tantrum on this matter.

I'm only really interested in what options the customers has in order
to get this all configured.  As long as there eventually ends up being
some path forward I'll be good with whatever ends up happening, though
my preference would be to see some option available in the kernel.

- Alex
