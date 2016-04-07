From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next] net: add the AF_KCM entries to family name
 tables
Date: Thu, 7 Apr 2016 04:52:30 +0000
Message-ID: <BLUPR03MB14108769385C992B84F3C4AFBF900@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1459867271-14592-1-git-send-email-decui@microsoft.com>
	<20160406.165939.2239653335603964561.davem@davemloft.net>
	<BLUPR03MB1410E0524104C8211C7C3559BF900@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160406.235914.1353594601077158951.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0138.outbound.protection.outlook.com ([65.55.169.138]:62645
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750817AbcDGEwf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 00:52:35 -0400
In-Reply-To: <20160406.235914.1353594601077158951.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 7, 2016 11:59
> To: Dexuan Cui <decui@microsoft.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] net: add the AF_KCM entries to family name
> tables
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Thu, 7 Apr 2016 01:54:18 +0000
> 
> > Can you please apply this to net-next too?
> 
> That will happen transparently the next time I merge 'net' into
> 'net-next'.
> 
> It will happen at a time of my own choosing, and usually occurs
> when I do a push of my 'net' tree to Linus and he takes it in,
> and I know people need some 'net' things in 'net-next'.

Thanks for the explanation!

So, at present, let me only post the single AF_HYPERV patch to
net-next and hold the patch that adds AF_HYPERV entries to the family
name tables.

Thanks,
-- Dexuan
