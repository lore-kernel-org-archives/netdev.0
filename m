From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH 2/2] SOCK: add raw6 drops counter
Date: Wed, 14 Nov 2007 12:50:47 +0800
Message-ID: <473A7EA7.9070706@cn.fujitsu.com>
References: <47397514.2070002@cn.fujitsu.com>	<473A6792.10405@cn.fujitsu.com>	<473A686D.9020200@cn.fujitsu.com> <20071113.203141.215714094.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:56185 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754852AbXKNExH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2007 23:53:07 -0500
In-Reply-To: <20071113.203141.215714094.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller said the following on 2007-11-14 12:31:
> From: Wang Chen <wangchen@cn.fujitsu.com>
> Date: Wed, 14 Nov 2007 11:15:57 +0800
> 
>> Add raw drops counter for IPv6 in /proc/net/raw6 .
>>
>> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
> 
> Applied to net-2.6.25, but again more whitespace problems:
> 
> Adds trailing whitespace.
> diff:9:		atomic_inc(&sk->sk_drops);	
> 

Sorry for that. I will pay more attention to it.
Thank you.


