From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] New Kernel Bugs
Date: Tue, 13 Nov 2007 03:39:46 -0800 (PST)
Message-ID: <20071113.033946.114918709.davem@davemloft.net>
References: <32209efe0711122242m3a5f081asf1c11a38b24db10c@mail.gmail.com>
	<20071113031553.3c7b5c16.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: protasnb@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: akpm@linux-foundation.org
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071113031553.3c7b5c16.akpm@linux-foundation.org>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 13 Nov 2007 03:15:53 -0800

> > NETWORKING===========================================================
> > 
> > RTNLGRP_ND_USEROPT does not report ifindex (IPv6)
> > http://bugzilla.kernel.org/show_bug.cgi?id=9349
> > Kernel: 2.6.24+
> 
> No response from developers

That's funny, then how come there was a proper patch fix posted
and it's now in my tree ready to go to Linus?

I think you like just saying "No response from developers" over and
over again to make some of point about how developers are ignoring
lots of bugs.  That's fine, but at least be accurate about it :-)
