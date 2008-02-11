From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] net: NEWEMAC: Remove "rgmii-interface" from rgmii matching
 table
Date: Mon, 11 Feb 2008 11:08:17 -0500
Message-ID: <47B072F1.4040605@garzik.org>
References: <1202300519-7294-1-git-send-email-sr@denx.de> <20080206064947.7e91d833@zod.rchland.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stefan Roese <sr@denx.de>, netdev@vger.kernel.org,
	benh@kernel.crashing.org, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:51961 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755055AbYBKQIX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Feb 2008 11:08:23 -0500
In-Reply-To: <20080206064947.7e91d833@zod.rchland.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> On Wed,  6 Feb 2008 13:21:59 +0100
> Stefan Roese <sr@denx.de> wrote:
> 
>> With the removal the the "rgmii-interface" device_type property from the
>> dts files, the newemac driver needs an update to only rely on compatible
>> property.
>>
>> Signed-off-by: Stefan Roese <sr@denx.de>
>> Acked-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> 
> Acked-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>

upon further reflection, ACK, take this via ppc tree



