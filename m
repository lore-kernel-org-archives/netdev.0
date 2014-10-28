From: Rongqing Li <rongqing.li@windriver.com>
Subject: Re: [PATCH iproute2] xfrm: add support of ESN and anti-replay window
Date: Tue, 28 Oct 2014 16:30:12 +0800
Message-ID: <544F5414.4080607@windriver.com>
References: <1413796984-9867-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>,
	dingzhi <zhi.ding@6wind.com>,
	Adrien Mazarguil <adrien.mazarguil@6wind.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51252 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbaJ1IaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Oct 2014 04:30:15 -0400
In-Reply-To: <1413796984-9867-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 10/20/2014 05:23 PM, Nicolas Dichtel wrote:
> From: dingzhi <zhi.ding@6wind.com>
>
> This patch allows to configure ESN and anti-replay window.
>
> Signed-off-by: dingzhi <zhi.ding@6wind.com>
> Signed-off-by: Adrien Mazarguil <adrien.mazarguil@6wind.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>   ip/ipxfrm.c     | 57 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
>   ip/xfrm_state.c | 59 ++++++++++++++++++++++++++++++++++++++++++++++++++-------

Docs or man needs to be updated.

-Roy
