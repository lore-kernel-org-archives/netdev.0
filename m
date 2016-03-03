From: David Miller <davem@davemloft.net>
Subject: Re: net_sched: dsmark: use qdisc_dequeue_peeked()
Date: Thu, 03 Mar 2016 00:52:48 -0500 (EST)
Message-ID: <20160303.005248.1802511283873870529.davem@davemloft.net>
References: <1456891804.3297.51.camel@kyeongy-dl>
	<CAM_iQpWGtRfbbGKD6i+XY0epgNkn=mNGnWG31dLhq7XLykdvFQ@mail.gmail.com>
	<1456953590.3297.58.camel@kyeongy-dl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, netdev@vger.kernel.org
To: Kyeong.Yoo@alliedtelesis.co.nz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36371 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751002AbcCCFww (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 00:52:52 -0500
In-Reply-To: <1456953590.3297.58.camel@kyeongy-dl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kyeong Yoo <Kyeong.Yoo@alliedtelesis.co.nz>
Date: Wed, 2 Mar 2016 21:19:51 +0000

> Author: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
> 
> net_sched: dsmark: use qdisc_dequeue_peeked()
 ...
> On Wed, 2016-03-02 at 10:26 -0800, Cong Wang wrote:
>> On Tue, Mar 1, 2016 at 8:10 PM, Kyeong Yoo
>> <Kyeong.Yoo@alliedtelesis.co.nz> wrote:

Please do not submit patches like this.

Specifically, do not reply to feedback you are given in order
to submit a new version of a patch.

Instead, make a new, fresh, list posting for the new version of
your patch.  Indicate that this is a new version of the patch
by putting something like "[net-next v2] net_sched: dsmark: ..."
in your Subject line.
