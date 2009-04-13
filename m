From: Alexander Beregalov <a.beregalov@gmail.com>
Subject: Re: [PATCH 01/11] xtsonic: convert to net_device_ops
Date: Tue, 14 Apr 2009 03:12:27 +0400
Message-ID: <a4423d670904131612pacc4f7fj4e8d03612a41a9b8@mail.gmail.com>
References: <20090411173019.GA16999@orion>
	 <20090413.151904.74427510.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f165.google.com ([209.85.219.165]:36713 "EHLO
	mail-ew0-f165.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084AbZDMXM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 19:12:29 -0400
Received: by ewy9 with SMTP id 9so2370855ewy.37
        for <netdev@vger.kernel.org>; Mon, 13 Apr 2009 16:12:27 -0700 (PDT)
In-Reply-To: <20090413.151904.74427510.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/4/14 David Miller <davem@davemloft.net>:
> From: Alexander Beregalov <a.beregalov@gmail.com>
> Date: Sat, 11 Apr 2009 21:30:19 +0400
>
>> Signed-off-by: Alexander Beregalov <a.beregalov@gmail.com>
>
> Applied.

Thanks David.

It seems build should not fail with !CONFIG_COMPAT_NET_DEV_OPS anymore.
Perhaps it can be changed to "default n" in next release (-next and 2.6.31) ?
