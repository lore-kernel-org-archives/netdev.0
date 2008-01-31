From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/6] preparations to enable netdevice notifiers inside
 a namespace (resend)
Date: Thu, 31 Jan 2008 15:58:36 +0100
Message-ID: <47A1E21C.40909@free.fr>
References: <47A1B835.7050600@sw.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=KOI8-R; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Containers <containers@lists.osdl.org>,
	netdev <netdev@vger.kernel.org>
To: "Denis V. Lunev" <den@sw.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([195.212.29.139]:42775 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759560AbYAaPDg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 10:03:36 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate6.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0VF3IBE268916
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 15:03:18 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0VF3IbZ3907616
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 15:03:18 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0VF3HWv025191
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 15:03:18 GMT
In-Reply-To: <47A1B835.7050600@sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Denis V. Lunev wrote:
> Here are some preparations and cleanups to enable network device/inet
> address notifiers inside a namespace.
> 
> This set of patches has been originally sent last Friday. One cleanup
> patch from the original series is dropped as wrong, thanks to Daniel
> Lezcano.

Can you explain please.
