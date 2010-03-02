From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: RE: [PATCH 0/8]: Bug fixes and new FW patch series
Date: Tue, 2 Mar 2010 11:42:10 -0800
Message-ID: <8628FE4E7912BF47A96AE7DD7BAC0AADCB46A2B4B1@SJEXCHCCR02.corp.ad.broadcom.com>
References: <1266408196.25691.841.camel@lb-tlvb-vladz>
 <20100217.134451.10225453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4127 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751295Ab0CBTmZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Mar 2010 14:42:25 -0500
In-Reply-To: <20100217.134451.10225453.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I'll surely do. Sorry for the inconvenience. 

vlad

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net] 
> Sent: Wednesday, February 17, 2010 11:45 PM
> To: Vladislav Zolotarov
> Cc: netdev@vger.kernel.org
> Subject: Re: [PATCH 0/8]: Bug fixes and new FW patch series
> 
> From: "Vladislav Zolotarov" <vladz@broadcom.com>
> Date: Wed, 17 Feb 2010 14:03:16 +0200
> 
> > Dave, hi.
> > Pls., apply the following series of patches.
> > It includes a few bugs fixes and a few FW.
> > 
> > The patches may also be found at
> > http://linux.broadcom.com/eilong/1.52.1-6
> 
> All applied, but please coordinate better with changes coming in via
> your colleages.
> 
> Patch #6 would not apply cleanly because the firmware/Makefile is
> different due to the bnx2 driver firmware updates made yesterday.
> 
> I fixed it up by hand, but in the future apply patches that apply
> cleanly to the current tree.
> 
> Thanks.
> 
> 
