From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 00/14] E1000 bugfix series for 2.6.20
Date: Fri, 15 Dec 2006 09:07:48 -0500
Message-ID: <4582AC34.9060408@garzik.org>
References: <1166174907.3365.108.camel@laptopd505.fenrus.org> <4582AB02.3010609@garzik.org> <4582AB67.4000201@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54968 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752169AbWLOOHu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Dec 2006 09:07:50 -0500
To: Arjan van de Ven <arjan@linux.intel.com>
In-Reply-To: <4582AB67.4000201@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arjan van de Ven wrote:
> Jeff Garzik wrote:
>> Arjan van de Ven wrote:
>>> Hi,
>>>
>>> this patch series contains critical bugfixes to the e1000 driver for
>>> 2.6.20 (and 3 very low intrusive features that help in testing). Without
>>> these patches e1000 is totally unusable on my test machine.
>>
>> Didn't Auke just submit these, and have them ACKd/NAKd as appropriate?
>>
> 
> they're not in 2.6.20-rc1 so I suspect they didn't go anywhere...
> (and Auke is on holiday for a bit afaik)

They didn't get applied because the patches need the revisions I requested.

	Jeff



