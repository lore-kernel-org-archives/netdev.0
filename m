From: Brian King <brking@linux.vnet.ibm.com>
Subject: Re: [PATCH][IBMVETH]: Use single_open instead of manual manipulations.
Date: Wed, 05 Mar 2008 08:59:16 -0600
Message-ID: <47CEB544.6060002@linux.vnet.ibm.com>
References: <47B9640E.8000701@openvz.org> <47CE80F4.60901@garzik.org> <47CE831C.4030508@openvz.org>
Reply-To: brking@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:56810 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752875AbYCEO7V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 09:59:21 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m25ExIHJ010712
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:59:18 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25ExIBS091254
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:59:18 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25ExH1I002816
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:59:18 -0500
In-Reply-To: <47CE831C.4030508@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Jeff Garzik wrote:
>> Pavel Emelyanov wrote:
>>> The code opening proc entry for each device makes the
>>> same thing, as the single_open does, so remove the
>>> unneeded code.
>>>
>>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>> ACK from ibmveth maintainer?
>>
> 
> There's no such in MAINTAINERS file. Git log since 2.6.22 shows
> Brian King as main contributor, he is in Cc and no reply from him.

Acked-by: Brian King <brking@linux.vnet.ibm.com>

-- 
Brian King
Linux on Power Virtualization
IBM Linux Technology Center
