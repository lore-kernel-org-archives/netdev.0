From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH net-next] net: add the AF_KCM entries to family name
 tables
Date: Thu, 7 Apr 2016 01:54:18 +0000
Message-ID: <BLUPR03MB1410E0524104C8211C7C3559BF900@BLUPR03MB1410.namprd03.prod.outlook.com>
References: <1459867271-14592-1-git-send-email-decui@microsoft.com>
 <20160406.165939.2239653335603964561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2on0103.outbound.protection.outlook.com ([207.46.100.103]:60151
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753173AbcDGCKb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 22:10:31 -0400
In-Reply-To: <20160406.165939.2239653335603964561.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Thursday, April 7, 2016 5:00
> To: Dexuan Cui <decui@microsoft.com>
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH net-next] net: add the AF_KCM entries to family name
> tables
> 
> From: Dexuan Cui <decui@microsoft.com>
> Date: Tue,  5 Apr 2016 07:41:11 -0700
> 
> > This is for the recent kcm driver, which introduces AF_KCM(41) in
> > b7ac4eb(kcm: Kernel Connection Multiplexor module).
> >
> > Signed-off-by: Dexuan Cui <decui@microsoft.com>
> > Cc: Signed-off-by: Tom Herbert <tom@herbertland.com>
> 
> As this is a bug fix actually, applied to 'net'.
David, 
Can you please apply this to net-next too?

It looks net-next is open now and I'm going to resubmit my
AF_HYPERV patchset, which needs to add AF_HYPERV entries to the 
family name tables too.

Thanks,
-- Dexuan
