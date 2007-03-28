From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [1/5] 2.6.21-rc5: known regressions
Date: Wed, 28 Mar 2007 21:23:27 +0200
Message-ID: <20070328192327.GA24340@elte.hu>
References: <Pine.LNX.4.64.0703251559560.6730@woody.linux-foundation.org> <20070327015929.GY16477@stusta.de> <460AB9E8.8070803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	e1000-devel@lists.sourceforge.net, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:38251 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932404AbXC1TYv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 15:24:51 -0400
Content-Disposition: inline
In-Reply-To: <460AB9E8.8070803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Kok, Auke <auke-jan.h.kok@intel.com> wrote:

> Adrian Bunk wrote:
> >Subject    : e1000 resume weirdness
> >References : http://lkml.org/lkml/2007/3/26/91
> >Submitter  : Ingo Molnar <mingo@elte.hu>
> >Handled-By : Jesse Brandeburg <jesse.brandeburg@gmail.com>
> >             Auke Kok <auke-jan.h.kok@intel.com>
> >Status     : problem is being debugged

> Adrian, you probably want to drop this issue from your list.

agreed - i have done many suspend/resumes meanwhile, and this condition 
has not reoccured since then. (and even when it occured, it was 
transitionary)

	Ingo
