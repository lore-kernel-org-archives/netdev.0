From: David Miller <davem@davemloft.net>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison
 overwritten
Date: Wed, 23 Jul 2008 15:31:43 -0700 (PDT)
Message-ID: <20080723.153143.10048360.davem@davemloft.net>
References: <20080721.163349.113841731.davem@davemloft.net>
	<20080722075000.GB15807@elte.hu>
	<20080722133415.GA23046@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, penberg@cs.helsinki.fi,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	vegard.nossum@gmail.com, rjw@sisk.pl, cl@linux-foundation.org,
	auke-jan.h.kok@intel.com, jeffrey.t.kirsher@intel.com
To: mingo@elte.hu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756051AbYGWWb6@vger.kernel.org>
In-Reply-To: <20080722133415.GA23046@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ingo Molnar <mingo@elte.hu>
Date: Tue, 22 Jul 2008 15:34:15 +0200

> it's now past 50 successful iterations with e1000e+netconsole enabled 
> again with the fix applied, and not a single crash, hang, memory 
> corruption or other weirdness happened. Jeff, please apply the fix 
> below.

I'll take care of integrating this, thanks Ingo.
