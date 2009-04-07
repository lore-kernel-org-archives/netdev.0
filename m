From: Jesse Barnes <jbarnes@virtuousgeek.org>
Subject: Re: [GIT]: Networking
Date: Tue, 7 Apr 2009 09:04:29 -0700
Message-ID: <20090407090429.6d29a23e@hobbes>
References: <20090406.190745.263215778.davem@davemloft.net>
	<alpine.LFD.2.00.0904061931160.4010@localhost.localdomain>
	<20090406202441.1c050ec6@hobbes>
	<20090406.210426.38766000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759879AbZDGQFr@vger.kernel.org>
In-Reply-To: <20090406.210426.38766000.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 06 Apr 2009 21:04:26 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Jesse Barnes <jbarnes@virtuousgeek.org>
> Date: Mon, 6 Apr 2009 20:24:41 -0700
> 
> > On Mon, 6 Apr 2009 19:32:11 -0700 (PDT)
> > Linus Torvalds <torvalds@linux-foundation.org> wrote:
> > 
> >> On Mon, 6 Apr 2009, David Miller wrote:
> >> 
> >> > From: Linus Torvalds <torvalds@linux-foundation.org>
> >> > Date: Mon, 6 Apr 2009 18:25:31 -0700 (PDT)
> >> > > 
> >> > > 
> >> > > The sky2 driver is buggered (by the previous pull, I presume).
> >> > > Some PCI interaction. NULL pointer dereference at boot.
> >> > 
> >> > Fixed in the PCI tree, have you pulled that one yet?
> >> 
> >> Nobody has even _asked_ me to pull.
> >> 
> >> What's the point of having fixes available if they aren't merged?
> > 
> > I just pushed it into my repo today and wanted at least a day of
> > linux-next before asking you to pull.
> 
> I feel like I've been watching people get pointed to that fix
> for what seems like days.
> 
> In fact this is why I was under the impression that you had
> already asked Linus to merge the fix. :-)

It came in right as I was putting together my tree for the merge
window; putting it in along with a few other fixes would have meant a
delay to do more testing etc so I figured I'd put it off until now.
Sorry about that; I didn't know so many people were running into it.

-- 
Jesse Barnes, Intel Open Source Technology Center
