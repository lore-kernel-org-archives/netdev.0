From: David Miller <davem@davemloft.net>
Subject: Re: [MACVLAN]: Fix memleak on device removal/crash on module
 removal
Date: Thu, 08 May 2008 01:14:05 -0700 (PDT)
Message-ID: <20080508.011405.223859547.davem@davemloft.net>
References: <48215DAC.1070704@trash.net>
	<48222727.2090606@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46436
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752465AbYEHIOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 May 2008 04:14:11 -0400
In-Reply-To: <48222727.2090606@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Wed, 07 May 2008 15:03:19 -0700

> Patrick McHardy wrote:
> > 
> > ------------------------------------------------------------------------
> > 
> > commit 2fe876e51d1f053b55d8d50c3733b136b6add016
> > Author: Patrick McHardy <kaber@trash.net>
> > Date:   Wed May 7 09:43:05 2008 +0200
> > 
> >     [MACVLAN]: Fix memleak on device removal/crash on module removal
> 
> Thanks.  I just tested this on 2.6.23 and it seems to fix the crash.

I've applied this to net-2.6, and will queue it up for net-2.6
as well.

Thanks again!
