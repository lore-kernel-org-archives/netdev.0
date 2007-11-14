From: James Bottomley <James.Bottomley@HansenPartnership.com>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 14:09:14 -0600
Message-ID: <1195070954.8364.41.camel@localhost.localdomain>
References: <20071113134029.GA30978@elte.hu>
	 <20071113085514.3414aa52.rdunlap@xenotime.net>
	 <20071114140847.GA11489@elte.hu>
	 <20071114.115601.00715073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: mingo@elte.hu, rdunlap@xenotime.net, akpm@linux-foundation.org,
	protasnb@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, alsa-devel@alsa-project.org,
	linux-ide@vger.kernel.org, linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20071114.115601.00715073.davem@davemloft.net>
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-11-14 at 11:56 -0800, David Miller wrote:
> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 14 Nov 2007 15:08:47 +0100
> 
> > In fact this thread is the very example: David points out that on netdev 
> > some of those bugs were already discussed and resolved. Had it been all 
> > on lkml we'd all be aware of it.
> 
> That's a rediculious argument.
> 
> One other reason these bugs are resolved, is that the networking
> developers only need to subscribe to netdev and not have to listen to
> all the noise on lkml.
> 
> People who want to manage bugs know what list to look on and
> contact about problems.
> 
> Dumping even more crap on lkml is not the answer.

I agree totally with David, and this goes for SCSI too.  If it's not
reported on linux-scsi, there's a significant chance of us missing the
bug report.  The fact that some people notice bugs go past on LKML and
forward them to linux-scsi is a happy accident and not necessarily
something to rely on.

LKML has 10-20x the traffic of linux-scsi and a much smaller signal to
noise ratio.  Having a specialist list where all the experts in the
field hangs out actually enhances our ability to fix bugs.

James
 

