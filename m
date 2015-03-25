From: David Miller <davem@davemloft.net>
Subject: Re: Please backport dev_kfree_skb_any fixes for stable
Date: Wed, 25 Mar 2015 14:03:58 -0400 (EDT)
Message-ID: <20150325.140358.1369150767101881939.davem@davemloft.net>
References: <CAHTgTXX2rw9441stUb41EHTKanm9HZ+4T+a5+fur4O6G7zy21A@mail.gmail.com>
	<20150324.001408.1364899234285488351.davem@davemloft.net>
	<CAHTgTXWvDs4fTg_Gpsn8XrYnHbgZOKC4ymkq_QVdnGVCOaiqzw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, netdev@vger.kernel.org,
	cwang@twopensource.com
To: vlee@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48413 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932159AbbCYSEC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 14:04:02 -0400
In-Reply-To: <CAHTgTXWvDs4fTg_Gpsn8XrYnHbgZOKC4ymkq_QVdnGVCOaiqzw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vinson Lee <vlee@twopensource.com>
Date: Wed, 25 Mar 2015 10:48:47 -0700

> On Mon, Mar 23, 2015 at 9:14 PM, David Miller <davem@davemloft.net> wrote:
>> From: Vinson Lee <vlee@twopensource.com>
>> Date: Tue, 17 Mar 2015 16:52:20 -0700
>>
>>> This stable request seems to have been forgotten.
>>
>> Sorry I've lost all of the context for this, you'll have to remind me
>> of all of the details.
> 
> These patches fixes warnings that can occur when a netconsole message
> is transmitted in an IRQ.

I mean the full context, as in the list of commits you'd like me to
queue up for -stable, and what -stable releases they are relevant
for.
