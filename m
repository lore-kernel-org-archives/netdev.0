From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/5] sky2: restore vlan acceleration on reset
Date: Wed, 21 May 2008 13:12:02 -0400
Message-ID: <483457E2.70605@pobox.com>
References: <20080515000412.984337700@vyatta.com> <20080515000432.887028646@vyatta.com> <20080521100245.1fc77369@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:43641 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761961AbYEURMF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 May 2008 13:12:05 -0400
In-Reply-To: <20080521100245.1fc77369@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote:
> On Wed, 14 May 2008 17:04:13 -0700
> Stephen Hemminger <shemminger@vyatta.com> wrote:
> 
>> If device has to be reset by sky2_restart, then need to restore
>> the VLAN acceleration settings.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
>> ---
>> Please apply to 2.6.26
> 
> Okay, it has been a week with no reply, what is the status
> of these patches?

Ouch, I missed it, sorry.  Dug it out...


