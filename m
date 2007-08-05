From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [2/2] 2.6.23-rc2: known regressions with patches
Date: Sun, 5 Aug 2007 19:51:55 +0200
Message-ID: <20070805175155.GA3244@elte.hu>
References: <46B5F93A.1020100@googlemail.com> <46B5FA4C.2070700@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Pekka Enberg <penberg@cs.helsinki.fi>,
	Peter Zijlstra <peterz@infradead.org>,
	Jan Dittmer <jdi@l4x.org>, Thomas Renninger <trenn@suse.de>,
	Netdev <netdev@vger.kernel.org>,
	Joachim Deguara <joachim.deguara@amd.com>,
	Michael Chan <mchan@broadcom.com>, linux-scsi@vger.kernel.org,
	James Bottomley <James.Bottomley@steeleye.com>,
	Matthew Wilcox <matthew@wil.cx>,
	Seokmann Ju <seokmann.ju@qlogic.com>,
	Richard Lary <rlary@us.ibm.com>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:59304 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751825AbXHERwd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Aug 2007 13:52:33 -0400
Content-Disposition: inline
In-Reply-To: <46B5FA4C.2070700@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:

> Memory management
> 
> Subject         : [bug] SLUB & freeing locks
> References      : http://lkml.org/lkml/2007/7/26/90
> Last known good : ?
> Submitter       : Ingo Molnar <mingo@elte.hu>
> Caused-By       : ?
> Handled-By      : Peter Zijlstra <peterz@infradead.org>
> Patch           : http://lkml.org/lkml/2007/7/26/97
> Status          : patch available

fixed by commit 2208b764c14d0f1ad63da64b1a42db6077b6fe42.

	Ingo
