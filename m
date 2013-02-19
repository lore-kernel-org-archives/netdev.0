From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] net: move procfs code to net/core/net-procfs.c
Date: Tue, 19 Feb 2013 13:24:05 +0800
Message-ID: <51230C75.8050206@gmail.com>
References: <1361251233-25914-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:59779 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab3BSFYO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:24:14 -0500
Received: by mail-pa0-f54.google.com with SMTP id fa10so3142950pad.13
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 21:24:13 -0800 (PST)
In-Reply-To: <1361251233-25914-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/19/2013 01:20 PM, Cong Wang wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
>
> Similar to net/core/net-sysfs.c, group procfs code to
> a single unit.
>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

This is for net-next, sorry for missing it in $subject.
