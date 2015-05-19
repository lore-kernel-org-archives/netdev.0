From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH resend] README: clarify redistribution requirements
 covering patents
Date: Tue, 19 May 2015 17:22:25 -0400
Message-ID: <20150519212225.GD5093@merlin.infradead.org>
References: <1431626160-10885-1-git-send-email-mcgrof@do-not-panic.com>
 <5554E99A.5030302@broadcom.com>
 <CAB=NE6WxMid+eNOoHZ__kbvP3BktHuYip+fQwVDydJQbQ1No_g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arend van Spriel <arend@broadcom.com>,
	Kyle McMartin <kyle@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
To: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAB=NE6WxMid+eNOoHZ__kbvP3BktHuYip+fQwVDydJQbQ1No_g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, May 19, 2015 at 01:18:14PM -0700, Luis R. Rodriguez wrote:
> >>   Your commit should include an update to the WHENCE file clearly
> >>   identifying the licence under which the firmware is available, and
> >> -that it is redistributable. If the licence is long and involved, it's
> >> +that it is redistributable. Being redistributable includes ensuring
> >> +the firmware license provided includes an implicit or explicit
> >> +patent grant to end users to ensure full functionality of device
> >> +operation with the firmware. If the licence is long and involved, it's
> >
> >
> > Just nitpicking here, but there is 'license' and 'licence' being used here.
> > Better stick to one and preferably 'license'.
> 
> Fixed, will submit a v2.
> 

Heh, it doesn't help that we now have LICENSE.* and LICENCE.* in the
tree as well. :/ I believe, at least in my Commonwealth english, that
licence is the file, and license is the action of licensing. I should
probably rename the LICENSE.* files in the tree to match.

--Kyle
