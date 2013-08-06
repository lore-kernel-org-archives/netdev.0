From: Sedat Dilek <sedat.dilek@gmail.com>
Subject: Re: linux-next: Tree for Aug 6 [ wireless | iwlwifi | mac80211 ? ]
Date: Wed, 7 Aug 2013 01:14:38 +0200
Message-ID: <CA+icZUW4wJkDGuq4W3=uXeKmV=vS0-PdxrPDH60J1KT7Jbnd4g@mail.gmail.com>
References: <1375816128.8219.28.camel@jlt4.sipsolutions.net>
	<CA+icZUXaTYVc_iv3hny6Je9mVdX8KCVpFSNBeukS+Fh-347Wvw@mail.gmail.com>
	<1375816715.8219.29.camel@jlt4.sipsolutions.net>
	<CA+icZUXdAjEDgu2XrA4Dg2hsLDJYdFTCpJwiW6=ZUgULe2noyw@mail.gmail.com>
	<CA+icZUVmokQ1fKmtbuPyp7f5Z2wdFYfjG5HCAm4Kue7efyKV8w@mail.gmail.com>
	<20130806213006.078C72210F@mail.nwl.cc>
	<CA+icZUVk1HM-VVYcARvY7p5KBYz0YcY9+rW8s-nKPTeVYh4tgw@mail.gmail.com>
	<1375825538.10459.1.camel@jlt4.sipsolutions.net>
	<20130806215657.GA16410@order.stressinduktion.org>
	<CA+icZUWY8PfYeV-iaPCm4MZenNaHRboK6Kmc8=Fnse9_dwfdqg@mail.gmail.com>
	<20130806230749.GC16410@order.stressinduktion.org>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Sedat Dilek <sedat.dilek@gmail.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	wireless <linux-wireless@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f49.google.com ([74.125.82.49]:37319 "EHLO
	mail-wg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab3HFXOk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 19:14:40 -0400
In-Reply-To: <20130806230749.GC16410@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 7, 2013 at 1:07 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Wed, Aug 07, 2013 at 12:55:33AM +0200, Sedat Dilek wrote:
>> No, tested only with iwlwifi.
>> Can you try the patch from [1]?
>>
>> - Sedat -
>>
>> [1] http://marc.info/?l=linux-netdev&m=137582524017840&w=2
>
> Fixed the problem with virtio_net, too.
>
> Thanks,
>

Cool!
I retested with latest next-20130806 which is also fine with this patch.

- Sedat -

>   Hannes
>
