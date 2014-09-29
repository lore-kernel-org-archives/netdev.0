From: David Hendel <david@silicom.co.il>
Subject: RE: Silicom bypass driver promote from staging
Date: Mon, 29 Sep 2014 07:18:11 +0000
Message-ID: <3BFAEADE799AF145974162DF00E013AF018F8C8A94@exchange2010.silicom.local>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
 <20140807215115.GB19520@electric-eye.fr.zoreil.com>
 <3BFAEADE799AF145974162DF00E013AF018F8C5848@exchange2010.silicom.local>
 <20140929011035.GC1167@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>
To: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 105.74.80-QoS-user.in-addr.arpa ([80.74.105.217]:60712 "EHLO
	exchange2010.silicom.local" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751429AbaI2HSP convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 03:18:15 -0400
In-Reply-To: <20140929011035.GC1167@kroah.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

OK, sorry
Sending again,

Regards, David


-----Original Message-----
From: gregkh@linuxfoundation.org [mailto:gregkh@linuxfoundation.org] 
Sent: Monday, September 29, 2014 4:11 AM
To: David Hendel
Cc: Francois Romieu; netdev@vger.kernel.org; arnd@arndb.de; Anna Lukin
Subject: Re: Silicom bypass driver promote from staging

On Sat, Sep 27, 2014 at 06:54:22AM +0000, David Hendel wrote:
> This is what we changed in updated patch:
> 1. Avoid redefining BIT and MII .
> 2. Fixing returning with spinlock held 3. Remove BP_SYNC_FLAG 4. Use 
> void __iomem * instead of long long in ioremap return 5. Cleanup with 
> checkpatch.pl

You sent an attached, compressed, set of patches, we can't do much at all with them, sorry.  Please attach them in the proper format as described in Documentation/SubmittingPatches.

thanks,

greg k-h
