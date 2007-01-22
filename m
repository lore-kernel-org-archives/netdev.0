From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [git patches] net driver fixes
Date: Mon, 22 Jan 2007 14:20:24 -0500
Message-ID: <45B50E78.7000107@garzik.org>
References: <20070122185508.GA4648@havoc.gtf.org> <45B50A73.7000000@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41813 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751783AbXAVTUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Jan 2007 14:20:31 -0500
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <45B50A73.7000000@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> Jeff Garzik wrote:
>> Please pull from 'upstream-linus' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git 
>> upstream-linus
> 
> Jeff,
> 
> is there a reason that you didn't pull the e1000 tree from us? I send 
> you all the information 5 days ago, WITH the changes that you requested.

I did pull the tree.  The fixes were far more than just obvious 
one-liners, so they got pulled into #upstream.

Given the past history of breakage during -rc from huge Intel "fix" 
patchsets, there's no way I'm going to push those fixes to Linus without 
plenty of testing in -mm first.

	Jeff



