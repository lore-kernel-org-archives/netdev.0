From: Andreas Mohr <andi@lisas.de>
Subject: Re: [usb regression] Re: [PATCH 2.6.24-rc3] Fix /proc/net breakage
Date: Wed, 2 Jan 2008 07:04:22 +0100
Message-ID: <20080102060422.GA30929@rhlx01.hs-esslingen.de>
References: <20071230161405.GA27788@elte.hu> <Pine.LNX.4.44L0.0712301526090.1963-100000@netrider.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Mohr <andi@lisas.de>, Ingo Molnar <mingo@elte.hu>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Woodhouse <dwmw2@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>,
	kernel list <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Pavel Emelyanov <xemul@openvz.org>,
	"Denis V. Lunev" <den@openvz.org>, Greg KH <greg@kroah.com>
To: Alan Stern <stern@rowland.harvard.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhlx01.hs-esslingen.de ([129.143.116.10]:38221 "EHLO
	rhlx01.hs-esslingen.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754606AbYABGEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jan 2008 01:04:23 -0500
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L0.0712301526090.1963-100000@netrider.rowland.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Sun, Dec 30, 2007 at 03:34:45PM -0500, Alan Stern wrote:
> It looks like Greg misused the debugfs API -- which is ironic, because
> he wrote debugfs in the first place!  :-)
> 
> Let me know if this patch fixes the problem.  If it does, I'll submit 
> it to Greg with all the proper accoutrements.

Finally a 2.6.24-rc6-mm1 with working USB WLAN. :)
IOW I can confirm that this was the cause of the USB problem I was having.

Thanks!

Andreas Mohr
