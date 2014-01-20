From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 v2 2/2] netem: add 64bit rates support
Date: Mon, 20 Jan 2014 12:37:31 -0800
Message-ID: <20140120123731.1674ddaf@nehalam.linuxnetplumber.net>
References: <1389841754-22008-1-git-send-email-yangyingliang@huawei.com>
	<1389841754-22008-3-git-send-email-yangyingliang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <eric.dumazet@gmail.com>
To: Yang Yingliang <yangyingliang@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f41.google.com ([209.85.160.41]:65466 "EHLO
	mail-pb0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750773AbaATUhe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jan 2014 15:37:34 -0500
Received: by mail-pb0-f41.google.com with SMTP id up15so6929880pbc.28
        for <netdev@vger.kernel.org>; Mon, 20 Jan 2014 12:37:34 -0800 (PST)
In-Reply-To: <1389841754-22008-3-git-send-email-yangyingliang@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 16 Jan 2014 11:09:14 +0800
Yang Yingliang <yangyingliang@huawei.com> wrote:

> netem support 64bit rates start from linux-3.13.
> Add 64bit rates support in tc tools.
> 
> tc qdisc show dev eth0
> qdisc netem 1: dev eth4 root refcnt 2 limit 1000 rate 35Gbit
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Yang Yingliang <yangyingliang@huawei.com>

Applied to net-next-3.13 branch
