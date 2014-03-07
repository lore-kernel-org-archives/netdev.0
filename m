From: Yang Yingliang <yangyingliang@huawei.com>
Subject: Re: [PATCH net-next 0/5] net_sched: Adjust qdisc_change() for command
 "#tc qdisc change/replace ..."
Date: Fri, 7 Mar 2014 10:16:22 +0800
Message-ID: <53192BF6.6010909@huawei.com>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com> <20140306131654.GA1826@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:14030 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229AbaCGCRc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 21:17:32 -0500
In-Reply-To: <20140306131654.GA1826@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/3/6 21:16, Hagen Paul Pfeifer wrote:
> * Yang Yingliang | 2014-03-06 21:08:36 [+0800]:
> 
>> Current commands "#tc qdisc replace..." and "#tc qdisc change..."
>> are not doing what they're supposed to do.
> 
> ... <snip>
> 
> Problem: thousands of scripts may expect exactly this unexpected behavior.
> 
> Hagen

Yes, it breaks behavior of "tc qdisc change".

I will try another way.

Thanks!
