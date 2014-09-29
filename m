From: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>
Subject: Re: Silicom bypass driver promote from staging
Date: Sun, 28 Sep 2014 21:10:35 -0400
Message-ID: <20140929011035.GC1167@kroah.com>
References: <3BFAEADE799AF145974162DF00E013AF018F80FFCF@exchange2010.silicom.local>
 <20140805150957.GC27303@kroah.com>
 <3BFAEADE799AF145974162DF00E013AF018F814DAB@exchange2010.silicom.local>
 <20140807215115.GB19520@electric-eye.fr.zoreil.com>
 <3BFAEADE799AF145974162DF00E013AF018F8C5848@exchange2010.silicom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"arnd@arndb.de" <arnd@arndb.de>, Anna Lukin <annal@silicom.co.il>
To: David Hendel <david@silicom.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:33796 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaI2GQe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 02:16:34 -0400
Content-Disposition: inline
In-Reply-To: <3BFAEADE799AF145974162DF00E013AF018F8C5848@exchange2010.silicom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 27, 2014 at 06:54:22AM +0000, David Hendel wrote:
> This is what we changed in updated patch:
> 1. Avoid redefining BIT and MII .
> 2. Fixing returning with spinlock held
> 3. Remove BP_SYNC_FLAG
> 4. Use void __iomem * instead of long long in ioremap return
> 5. Cleanup with checkpatch.pl

You sent an attached, compressed, set of patches, we can't do much at
all with them, sorry.  Please attach them in the proper format as
described in Documentation/SubmittingPatches.

thanks,

greg k-h
