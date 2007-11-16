From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [BUG] New Kernel Bugs
Date: Thu, 15 Nov 2007 19:05:39 -0500
Message-ID: <20071116000539.GA3032@fieldses.org>
References: <20071113.033946.114918709.davem@davemloft.net> <20071113034916.2556edd7.akpm@linux-foundation.org> <20071113.035824.40509981.davem@davemloft.net> <20071113041259.79c9a8c5.akpm@linux-foundation.org> <20071113134029.GA30978@elte.hu> <20071113085514.3414aa52.rdunlap@xenotime.net> <20071114140847.GA11489@elte.hu> <20071114093820.ff3ad8f9.rdunlap@xenotime.net> <20071114182351.GI14254@fieldses.org> <18235.46083.293604.560507@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Randy Dunlap <rdunlap@xenotime.net>, Ingo Molnar <mingo@elte.hu>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:33981 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754408AbXKPAGE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 19:06:04 -0500
Content-Disposition: inline
In-Reply-To: <18235.46083.293604.560507@notabene.brown>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 15, 2007 at 01:50:43PM +1100, Neil Brown wrote:
> Virtual Folders.
> 
> I use VM mode in EMACS, but I believe some other mail readers have the
> same functionality.
> I have a virtual folder called "nfs" which shows me all mail in my
> inbox which has the string 'nfs' or 'lockd' in a To, Cc, or Subject
> field.  When I visit that folder, I see all mail about nfs, whether it
> was sent to me personally, or to a relevant list, or to lkml.

Hm (googling around for "mutt" and "virtual folders"): looks like I can
get most of the way there in mutt with some macros based on its "limit"
command:

	http://www.tummy.com/journals/entries/jafo_20060303_044440

Thanks.--b.
