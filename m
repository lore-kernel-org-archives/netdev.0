From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] TI DaVinci EMAC: Add EMAC PHY clock handling.
Date: Fri, 12 Mar 2010 14:33:50 -0800 (PST)
Message-ID: <20100312.143350.31570630.davem@davemloft.net>
References: <1268317491-3822-1-git-send-email-srk@ti.com>
	<1268317491-3822-2-git-send-email-srk@ti.com>
	<87bpet6urm.fsf@deeprootsystems.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srk@ti.com, netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: khilman@deeprootsystems.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57058
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934667Ab0CLWd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 17:33:29 -0500
In-Reply-To: <87bpet6urm.fsf@deeprootsystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kevin Hilman <khilman@deeprootsystems.com>
Date: Fri, 12 Mar 2010 14:27:09 -0800

> Sriramakrishnan <srk@ti.com> writes:
> 
>> Source for the EMAC PHY clock can be different from the
>> module clock and driver needs to request/enable the EMAC
>> phy clock explicitly. This was not required earlier as on
>> most Davinci platforms the phy clock is always on . On AM35x
>> platform the phy clock needs to be managed explicitly , hence
>> adding clock management for phy clock.
>>
>> Signed-off-by: Sriramakrishnan <srk@ti.com>
> 
> Acked-by: Kevin Hilman <khilman@deeprootsystems.com>
> 
> Dave, if you prefer, with your ack, I'll merge this via the davinci
> tree along with corresponding platform changes.

Please do:

Acked-by: David S. Miller <davem@davemloft.net>
