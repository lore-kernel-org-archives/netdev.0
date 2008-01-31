From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 0/6] preparations to enable netdevice notifiers inside
 a namespace (resend)
Date: Thu, 31 Jan 2008 18:46:46 +0100
Message-ID: <47A20986.9090701@free.fr>
References: <47A1B835.7050600@sw.ru> <47A1E21C.40909@free.fr> <939d53060801310847y31c4542do271edd48e44745c7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Denis V. Lunev" <den@sw.ru>,
	Linux Containers <containers@lists.osdl.org>,
	netdev <netdev@vger.kernel.org>
To: Benjamin Thery <ben.thery@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:27940 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753241AbYAaRvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 12:51:49 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id m0VHpXcj442676
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 17:51:33 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0VHpXqk3834014
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 17:51:33 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0VHpTuh017425
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 17:51:30 GMT
In-Reply-To: <939d53060801310847y31c4542do271edd48e44745c7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Thery wrote:
> On Jan 31, 2008 3:58 PM, Daniel Lezcano <daniel.lezcano@free.fr> wrote:
> 
>> Denis V. Lunev wrote:
>>> Here are some preparations and cleanups to enable network device/inet
>>> address notifiers inside a namespace.
>>>
>>> This set of patches has been originally sent last Friday. One cleanup
>>> patch from the original series is dropped as wrong, thanks to Daniel
>>> Lezcano.
>> Can you explain please.
> 
> 
> I think Denis refers to the patch called "3/7 Prohibit assignment of
> 0.0.0.0as interface address." ,
> he dropped because it was inappropriate, no?

Yes, you are right, Denis explained me in a private email. I think I 
really need to sleep a little more :)
