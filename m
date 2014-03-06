From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH net-next 0/5] net_sched: Adjust qdisc_change() for
 command "#tc qdisc change/replace ..."
Date: Thu, 6 Mar 2014 13:16:55 +0000
Message-ID: <20140306131654.GA1826@localhost.localdomain>
References: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	stephen@networkplumber.org, eric.dumazet@gmail.com
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:39980 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751721AbaCFNRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 08:17:03 -0500
Content-Disposition: inline
In-Reply-To: <1394111321-11192-1-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Yang Yingliang | 2014-03-06 21:08:36 [+0800]:

>Current commands "#tc qdisc replace..." and "#tc qdisc change..."
>are not doing what they're supposed to do.

... <snip>

Problem: thousands of scripts may expect exactly this unexpected behavior.

Hagen
