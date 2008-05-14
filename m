From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: Re: [PATCH] [SCTP]: Add address type check while process paramaters
 of ASCONF chunk
Date: Wed, 14 May 2008 08:56:21 +0800
Message-ID: <482A38B5.5030908@cn.fujitsu.com>
References: <1210360195-16524-2-git-send-email-vladislav.yasevich@hp.com>	<48297BE9.9020204@trash.net>	<48298E27.40100@hp.com> <20080513.153238.211668684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, kaber@trash.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:61404 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760926AbYENA4U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 May 2008 20:56:20 -0400
In-Reply-To: <20080513.153238.211668684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David:

 Sorry for my mistake. This patch is create and tested by me.

 I tested it used a test tool which is created by me. And this patchset 
resolved the kernel panic problem. It seems that I need to do more 
review my patch and
add more test case to my tool. I will pay more attention to do the 
correct patchs.

 Thanks everyone.

David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Tue, 13 May 2008 08:48:39 -0400
>
>   
>> I missed this warning in the my builds...
>>     
>
> And in your testing of the patch too, right?
>
>   
