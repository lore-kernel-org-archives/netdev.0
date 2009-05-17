From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [BUG 2.6.30-rc1] panic when loading oprofile
Date: Sun, 17 May 2009 10:38:36 +0200
Message-ID: <20090517083836.GL16682@one.firstfloor.org>
References: <alpine.WNT.2.00.0905131327430.7052__41366.1100705669$1242253861$gmane$org@jbrandeb-desk1.amr.corp.intel.com> <87fxf6pmh5.fsf@basil.nowhere.org> <20090516162017.2525511c.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	linux-kernel@vger.kernel.org, oprofile-list@lists.sourceforge.net,
	netdev@vger.kernel.org, rusty@rustcorp.com.au
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:55563 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751872AbZEQIc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 04:32:59 -0400
Content-Disposition: inline
In-Reply-To: <20090516162017.2525511c.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Ping?

We'll probably need to wait for Monday for Jesse trying that.

> 
> This is in Rafael's regression list but I suspect that it's a
> linux-next-only thing?

No, it was reproduced on rc5.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.
