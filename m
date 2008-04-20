From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [for 2.6.26] ISDN cleanups, ok for upstream?
Date: Sun, 20 Apr 2008 18:20:01 -0400
Message-ID: <480BC191.6030905@garzik.org>
References: <20080418225355.GA30189@havoc.gtf.org> <20080418164113.6863213d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kkeil@suse.de, isdn4linux@listserv.isdn4linux.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:50422 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750796AbYDTWUJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Apr 2008 18:20:09 -0400
In-Reply-To: <20080418164113.6863213d.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> On Fri, 18 Apr 2008 18:53:55 -0400
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> I don't know the current state of
>> akpm's pull of jgarzik/misc-2.6.git#ALL.
> 
> oops.  It seems that I disabled it quite a long time ago.   I'll resurrect
> it.

Thanks!  Though note that it will be temporary empty, after 
isdn-cleanups is sent upstream.

If it's not too much trouble, I would appreciate you continuing to poll 
misc-2.6.git#ALL, even if it comes up empty.  That tree (and branch) 
acts as an outlet for miscellaneous jgarzik stuff that may go upstream 
"vaguely soonish maybe"  :)


>> The 'isdn-cleanups' branch of
>> master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/misc-2.6.git isdn-cleanups
> 
> That merges cleanly against the small number of isdn patches which are
> pending in -mm, so we're OK from that POV.

Thanks for checking.

Regards,

	Jeff


