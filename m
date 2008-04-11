From: Mark Lord <lkml@rtr.ca>
Subject: Re: 2.6.25-rc8: FTP transfer errors
Date: Thu, 10 Apr 2008 21:23:54 -0400
Message-ID: <47FEBDAA.7010305@rtr.ca>
References: <47FEADCB.7070104@rtr.ca>	<20080410.172453.44434205.davem@davemloft.net>	<47FEB062.3020003@rtr.ca> <20080410.173911.179180620.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jesper.juhl@gmail.com, tilman@imap.cc, yoshfuji@linux-ipv6.org,
	jeff@garzik.org, rjw@sisk.pl, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758303AbYDKBYL@vger.kernel.org>
In-Reply-To: <20080410.173911.179180620.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Mark Lord <lkml@rtr.ca>
> Date: Thu, 10 Apr 2008 20:27:14 -0400
> 
>> It's *your* bug -- you signed off on the commit.
> 
> I sign off on basically every networking commit, does that mean I have
> to fix every networking bug and every networking bug is "mine"?
..

Absolutely, though to a varying degree.  That's the responsibility
that goes with the role of a subsystem maintainer.  I once had
such a role, and gave it up when I felt I could no longer keep up.  

You still keep refering to it as "your (my) bug".
It's not.  I had nothing to do with it, other than stumbling over it.

When people stumble over a libata bug, I look hard to see if my code
could possibly cause it.  Jeff looks even harder, because he's the
current subsystem dude for libata.

I never suggest a user search through a mountain of unrelated commits
for something I've screwed up on.  I give more directed help, patches
to collect more relevant information, and patches to try and resolve it.

The last thing I'd ever do, is diss the reporter.

Regards.
