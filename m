From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [ PATCH 1/1 2.6.25-rc9] bnx2: Add EEH support in bnx2
 driver - Resending
Date: Thu, 24 Apr 2008 17:34:08 -0700
Message-ID: <1209083648.6194.107.camel@dell>
References: <1208812834.24768.40.camel@wendyx.austin.ibm.com>
 <1208823296.16633.230.camel@dell>
 <1208893442.7339.17.camel@wendyx.austin.ibm.com>
 <1208900791.13806.5.camel@dell>
 <1208983008.7339.24.camel@wendyx.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, jeff@garzik.org,
	"David Miller" <davem@davemloft.net>
To: "wendy xiong" <wendyx@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4996 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751217AbYDXXau (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 19:30:50 -0400
In-Reply-To: <1208983008.7339.24.camel@wendyx.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-04-23 at 15:36 -0500, wendy xiong wrote:
> Hi Michael,
> 
> Thanks!
> I am re-sending patch with rtnl_lock()/rtnl_unlock().
> 
> Thanks,
> Wendy
> 

Thanks.  The patch is white-space damaged and won't apply the way it is.

I'll regenerate it and send it to DaveM when he opens up net-2.6.27
together with other patches in my queue.  He has announced earlier that
net-2.6.26 is no longer accepting new features.

Thanks.

