From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Move sctp_v4_dst_saddr out of loop
Date: Tue, 03 Jun 2008 11:41:00 -0400
Message-ID: <4845660C.2030200@hp.com>
References: <4844D993.7090705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:33295 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752712AbYFCPlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 11:41:06 -0400
In-Reply-To: <4844D993.7090705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gui

Gui Jianfeng wrote:
> There's no need to execute sctp_v4_dst_saddr() for each
> iteration, just move it out of loop.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

I'll put this in the set that I am getting ready to submit.

-vlad
