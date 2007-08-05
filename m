From: Thomas Renninger <trenn@suse.de>
Subject: Re: [2/2] 2.6.23-rc2: known regressions with patches
Date: Sun, 05 Aug 2007 18:39:36 +0200
Message-ID: <1186331976.3858.39.camel@fanta4.site>
References: <46B5F93A.1020100@googlemail.com>
	 <46B5FA4C.2070700@googlemail.com>
Reply-To: trenn@suse.de
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@elte.hu>, Jan Dittmer <jdi@l4x.org>,
	Netdev <netdev@vger.kernel.org>,
	Joachim Deguara <joachim.deguara@amd.com>,
	Michael Chan <mchan@broadcom.com>, linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@steeleye.com>,
	Matthew Wilcox <matthew@wil.cx>,
	Seokmann Ju <seokmann.ju@qlogic.com>,
	Richard Lary <rlary@us.ibm.com>, tony.luck@intel.com
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:59425 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756048AbXHEQin (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 12:38:43 -0400
In-Reply-To: <46B5FA4C.2070700@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2007-08-05 at 18:26 +0200, Michal Piotrowski wrote:
> Hi all,

> Modpost
> 
> Subject         : modpost bug breaks ia64 cross compilation
> References      : http://lkml.org/lkml/2007/7/27/30
>                   http://lkml.org/lkml/2007/7/27/418
> Last known good : ?
> Submitter       : Jan Dittmer <jdi@l4x.org>
> Caused-By       : Thomas Renninger <trenn@suse.de>
>                   commit 29b71a1ca74491fab9fed09e9d835d840d042690
> Handled-By      : ?
> Patch           : http://lkml.org/lkml/2007/8/2/211
> Status          : patch was suggested

A patch was sent to Tony. AFAIK it got accepted, not sure whether it
already is in any and which git tree...

> Networking
> 
> Subject         : tg3 dead after s2ram
> References      : http://lkml.org/lkml/2007/7/31/121
> Last known good : ?
> Submitter       : Joachim Deguara <joachim.deguara@amd.com>
> Caused-By       : ?
> Handled-By      : Michael Chan <mchan@broadcom.com>
> Patch           : http://lkml.org/lkml/2007/8/2/288
> Status          : patch available
> 
David Miller sent a message that it got applied.

Thanks,

   Thomas

