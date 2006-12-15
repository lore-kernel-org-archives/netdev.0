From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch 00/14] E1000 bugfix series for 2.6.20
Date: Fri, 15 Dec 2006 15:04:23 +0100
Message-ID: <4582AB67.4000201@linux.intel.com>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <4582AB02.3010609@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:44380 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752194AbWLOOOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Dec 2006 09:14:05 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <4582AB02.3010609@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Arjan van de Ven wrote:
>> Hi,
>>
>> this patch series contains critical bugfixes to the e1000 driver for
>> 2.6.20 (and 3 very low intrusive features that help in testing). Without
>> these patches e1000 is totally unusable on my test machine.
> 
> Didn't Auke just submit these, and have them ACKd/NAKd as appropriate?
> 

they're not in 2.6.20-rc1 so I suspect they didn't go anywhere...
(and Auke is on holiday for a bit afaik)
