From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
	overwritten
Date: Wed, 23 Jul 2008 15:40:56 -0700
Message-ID: <1216852856.4427.5.camel@jtkirshe-mobile.jf.intel.com>
References: <20080721.163349.113841731.davem@davemloft.net>
	 <20080722075000.GB15807@elte.hu> <20080722133415.GA23046@elte.hu>
	 <20080723.153143.10048360.davem@davemloft.net>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, johnpol@2ka.mipt.ru, penberg@cs.helsinki.fi,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vegard.nossum@gmail.com, rjw@sisk.pl, cl@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.250]:35676 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750799AbYGWWkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2008 18:40:55 -0400
Received: by an-out-0708.google.com with SMTP id d40so556976and.103
        for <netdev@vger.kernel.org>; Wed, 23 Jul 2008 15:40:54 -0700 (PDT)
In-Reply-To: <20080723.153143.10048360.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-07-23 at 15:31 -0700, David Miller wrote:
> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 22 Jul 2008 15:34:15 +0200
> 
> > it's now past 50 successful iterations with e1000e+netconsole enabled 
> > again with the fix applied, and not a single crash, hang, memory 
> > corruption or other weirdness happened. Jeff, please apply the fix 
> > below.
> 
> I'll take care of integrating this, thanks Ingo.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

Thanks Dave.  I have the patch in my queue of patches to push, just had
not pushed it to you and Jeff yet.

-- 
Cheers,
Jeff

