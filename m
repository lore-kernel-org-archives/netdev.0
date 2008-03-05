From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH][IBMVETH]: Use single_open instead of manual manipulations.
Date: Wed, 05 Mar 2008 14:25:16 +0300
Message-ID: <47CE831C.4030508@openvz.org>
References: <47B9640E.8000701@openvz.org> <47CE80F4.60901@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Brian King <brking@linux.vnet.ibm.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:35042 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYCEL0g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 06:26:36 -0500
In-Reply-To: <47CE80F4.60901@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff Garzik wrote:
> Pavel Emelyanov wrote:
>> The code opening proc entry for each device makes the
>> same thing, as the single_open does, so remove the
>> unneeded code.
>>
>> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> ACK from ibmveth maintainer?
> 

There's no such in MAINTAINERS file. Git log since 2.6.22 shows
Brian King as main contributor, he is in Cc and no reply from him.
