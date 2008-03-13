From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][IBMVETH]: Use single_open instead of manual manipulations.
Date: Thu, 13 Mar 2008 12:52:05 +0300
Message-ID: <47D8F945.7020404@openvz.org>
References: <47B9640E.8000701@openvz.org> <47CE80F4.60901@garzik.org> <47CE831C.4030508@openvz.org> <47CEB544.6060002@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: brking@linux.vnet.ibm.com,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:33337 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750807AbYCMJwh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Mar 2008 05:52:37 -0400
In-Reply-To: <47CEB544.6060002@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian King wrote:
> Pavel Emelyanov wrote:
>> Jeff Garzik wrote:
>>> Pavel Emelyanov wrote:
>>>> The code opening proc entry for each device makes the
>>>> same thing, as the single_open does, so remove the
>>>> unneeded code.
>>>>
>>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>>> ACK from ibmveth maintainer?
>>>
>> There's no such in MAINTAINERS file. Git log since 2.6.22 shows
>> Brian King as main contributor, he is in Cc and no reply from him.
> 
> Acked-by: Brian King <brking@linux.vnet.ibm.com>
> 

Jeff, what are your plans about this patch?

Thanks,
Pavel
