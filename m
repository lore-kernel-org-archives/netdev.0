From: "David S. Miller" <davem@redhat.com>
Subject: Re: networking bugs and bugme.osdl.org
Date: Fri, 27 Jun 2003 15:02:48 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030627.150248.08328103.davem@redhat.com>
References: <Pine.LNX.4.55.0306270749020.4137@bigblue.dev.mcafeelabs.com>
	<20030627.143738.41641928.davem@redhat.com>
	<Pine.LNX.4.55.0306271454490.4457@bigblue.dev.mcafeelabs.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mbligh@aracnet.com, linux-kernel@vger.kernel.org,
   linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: davidel@xmailserver.org
In-Reply-To: <Pine.LNX.4.55.0306271454490.4457@bigblue.dev.mcafeelabs.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Davide Libenzi <davidel@xmailserver.org>
   Date: Fri, 27 Jun 2003 15:02:00 -0700 (PDT)
   
   David, your method is the dream of every software developer.

It is not a dream, it works perfectly fine and has done so
for 5+ years of Linux maintainence.

To make these things scale you MUST push the work out to other people,
you absolutely cannot centralize.  And here we're pushing it out to
the bug reporters, just like we push the work of patch maintainence to
the patch submitters.

If they don't care about the bug and won't retransmit when their
stuff isn't being looked at, their bug isn't worth being looked
at.

I know that's a hard pill to swallow, but over years of work I can
tell you this is the only scalable mechanism.  Nobody likes this
because it's not tracked somewhere and they can't show some pretty
list of bugs to their management at the end of each week, TOO FUCKING
BAD.  Pay someone to work on your bugs if you want a pretty list and
people being REQUIRED to look at and fix bugs.  None of this crap is
my problem.
