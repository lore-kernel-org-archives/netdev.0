From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: possible kernel oops from user MSS
Date: Thu, 11 Nov 2010 13:37:45 +0800
Message-ID: <4CDB8129.6030802@cn.fujitsu.com>
References: <AANLkTimMDMb74-3E9vhFxZ5Dgeuk3HMzPZVjwCj+yFEJ@mail.gmail.com>	<20101110.124119.102563803.davem@davemloft.net>	<4CDB7BD5.6030204@cn.fujitsu.com> <20101110.213313.71108940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: schen@mvista.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57025 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751407Ab0KKFid (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Nov 2010 00:38:33 -0500
In-Reply-To: <20101110.213313.71108940.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote, at 11/11/2010 01:33 PM:
> From: Shan Wei <shanwei@cn.fujitsu.com>
> Date: Thu, 11 Nov 2010 13:15:01 +0800
> 
>> In tcp_connect_init(), if tcp_header_len includes TCPOLEN_TSTAMP_ALIGNED(12 bytes)
>> and TCPOLEN_MD5SIG_ALIGNED(20 bytes).
> 
> If you knew this, why didn't you mention it in your initial report? :-/

Firstly reported by Steve Chen, not me. :-)
I just review your patch.
 
> I'll make the minimum 64 or something like that.

Welcome. 


-- 
Best Regards
-----
Shan Wei
