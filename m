From: Andrew Morton <akpm@digeo.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 19:35:21 -0700
Sender: linux-net-owner@vger.kernel.org
Message-ID: <20030627193521.25040f3e.akpm@digeo.com>
References: <20030626.224739.88478624.davem@redhat.com>
	<21740000.1056724453@[10.10.2.4]>
	<Pine.LNX.4.55.0306270749020.4137@bigblue.dev.mcafeelabs.com>
	<20030627.143738.41641928.davem@redhat.com>
	<Pine.LNX.4.55.0306271454490.4457@bigblue.dev.mcafeelabs.com>
	<20030627213153.GR501@phunnypharm.org>
	<20030627162527.714091ce.akpm@digeo.com>
	<35240000.1056760723@[10.10.2.4]>
	<20030627181432.61bf6f3a.akpm@digeo.com>
	<36630000.1056766403@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bcollins@debian.org, davidel@xmailserver.org, davem@redhat.com,
	linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-net-owner@vger.kernel.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
In-Reply-To: <36630000.1056766403@[10.10.2.4]>
List-Id: netdev.vger.kernel.org

"Martin J. Bligh" <mbligh@aracnet.com> wrote:
>
> 1. default owners -> lists:
> 
> Setting default owners to existing lists is somewhat invasive, and
> might provoke riots ;-) Not only do you get the new bug notification,
> but also any updates, which may become irritating.

That's OK.  It is a matter of people being aware that the updates will be
echoed to a mailing list and acting appropriately.

If some low-value stuff leaks through then ho-hum, at least it was
on-topic.  It is not as if we are unused to low-value content...

It would be good if pure administrata such as changing the status were
filtered.

In fact, there is probably no point in sending anything bugzilla->list apart
from the initial report.  If the bug is then pursued via bugzilla then OK. 
If is is pursued via email then bugzilla just captures the discussion.   

> There's probably 
> some vaguely happy medium to be found between: 
> 	a) sending newly logged bugs to existing lists,
> 	b) sending updates to some new list.
> Maybe if we just create a new list for each category, and let
> people subscribe at will to those ... and I keep sending newly logged
> bugs to linux-kernel? I can cc netdev / linux-scsi / whatever on those
> new ones if that helps?

I think sending the initial report to the relevant lists and then capturing
incoming email would suffice.

> 2. email back in.
> 
> Email back in is harder, and needs more thought as to how to make it
> easy to use, whilst avoiding logging crap (eg. ensuing flamewars that 
> derive from the bug reports, etc).

Well hopefully people will have the sense to cut the bugzilla address off
the Cc line if it drifts off-topic.

> My intuition is to log replies by
> default, and hack off certain threads by hand

Nah.  Just log everything and hack off the crap by larting people.


