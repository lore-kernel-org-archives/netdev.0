From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH-v2] sctp: user perfect name for Delayed SACK Timer option
Date: Wed, 19 Jan 2011 16:54:00 +0800
Message-ID: <4D36A6A8.4020402@cn.fujitsu.com>
References: <4D3693CA.40508@cn.fujitsu.com> <4D36A324.4040307@cn.fujitsu.com> <4D36A557.6080708@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Network-Maillist <netdev@vger.kernel.org>,
	SCTP-Maillist <linux-sctp@vger.kernel.org>
To: Wei Yongjun <yjwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63322 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752593Ab1ASI5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 03:57:30 -0500
In-Reply-To: <4D36A557.6080708@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wei Yongjun wrote, at 01/19/2011 04:48 PM:
> 
>> The option name of Delayed SACK Timer should be SCTP_DELAYED_SACK,
>> not SCTP_DELAYED_ACK.
>>
>> Left SCTP_DELAYED_ACK be concomitant with SCTP_DELAYED_SACK,
>> for making compatibility with existing applications.
> 
> SCTP_DELAYED_ACK is introduced by my typo when change it to
> API compliance two years ago. So:
> 
> Acked-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Thanks for your work. 


-- 
Best Regards
-----
Shan Wei
