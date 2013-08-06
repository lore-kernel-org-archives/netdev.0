From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: low latency/busy poll feedback and bugs
Date: Tue, 06 Aug 2013 14:02:58 -0700
Message-ID: <1375822978.4004.12.camel@edumazet-glaptop>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com>
	 <5200A8BC.4010402@linux.intel.com>
	 <CAJZOPZKByh7LzH0w25dDG_5jOvg7wPrmiVcMJ0xBhOJxaE0Zcw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	"Rose, Gregory V" <gregory.v.rose@intel.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f44.google.com ([209.85.128.44]:62938 "EHLO
	mail-qe0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab3HFVDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Aug 2013 17:03:03 -0400
Received: by mail-qe0-f44.google.com with SMTP id 6so535329qeb.17
        for <netdev@vger.kernel.org>; Tue, 06 Aug 2013 14:03:01 -0700 (PDT)
In-Reply-To: <CAJZOPZKByh7LzH0w25dDG_5jOvg7wPrmiVcMJ0xBhOJxaE0Zcw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-06 at 23:39 +0300, Or Gerlitz wrote:
> On Tue, Aug 6, 2013 at 10:41 AM, Eliezer Tamir
> <eliezer.tamir@linux.intel.com> wrote:
> > On 06/08/2013 00:22, Shawn Bohrer wrote:
> >> 1) I'm testing with a Mellanox ConnectX-3 card.
> >
> > There's your problem ;)
> 
> Can you be more specific? I love testing with Intel Niantic, do code
> inspetion of the ixgbe driver and interact with Jeff/Greg/Alex/John
> and all the other great folks from the Intel Linux networking team,
> actually that (happily working with your competitors) is crucial part
> of the fun in open source / upstream work. What's wrong with using
> NICs which don't have intel.com on their paper cover?

I don't think there is something wrong.

Eliezer tone was quite clear ;)

BTW, I do not have a Niantic cards to play with, Intel guys feel free to
send me samples ;)

Thanks
