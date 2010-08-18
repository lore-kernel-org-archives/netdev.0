From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Broadcom 5709 take long time to bring up
Date: Wed, 18 Aug 2010 14:25:57 -0700
Message-ID: <4C6C4FE5.20509@hp.com>
References: <20100818143432.GA29386@joejin-pc.cn.oracle.com>	<1282147735.3880.83.camel@localhost> <70AE41F9-6FB7-43E3-A0C0-450E964A9B56@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Benjamin Li <benli@broadcom.com>, Joe Jin <joe.jin@oracle.com>,
	Michael Chan <mchan@broadcom.com>,
	"terry.liu@oracle.com" <terry.liu@oracle.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:36315 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab0HRV0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 17:26:00 -0400
In-Reply-To: <70AE41F9-6FB7-43E3-A0C0-450E964A9B56@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mitchell Erblich wrote:
> On Aug 18, 2010, at 9:08 AM, Benjamin Li wrote:
> 
> 
>>Hi Joe,
>>
>>Just a couple of quick questions:
>>
>>1.  It is possible that autonegotiation could take in the orders of
>>seconds depending on the remote partner.   
> 
> 
> No. It happens in ms.
> 
> Mitchell Erblich

Both may be correct, depending on the context.  The IEEE specs likely mandate 
that autonegotiation take no longer than N ms, but there may indeed be kit out 
there that takes rather longer...

rick jones
