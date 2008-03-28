From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] SCTP: Remove an useless parameter from
Date: Fri, 28 Mar 2008 09:36:00 -0400
Message-ID: <47ECF440.3030801@hp.com>
References: <47EC4F56.6000300@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	lksctp-dev <lksctp-developers@lists.sourceforge.net>,
	David Miller <davem@davemloft.net>
To: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:35322 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbYC1NgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 09:36:02 -0400
In-Reply-To: <47EC4F56.6000300@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gui Jianfeng wrote:
> Vlad,
> There is an useless parameter in sctp_cmd_hb_timer_update,
> remove it.
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

Applied, thanks.  Will push to David shortly.

-vlad
