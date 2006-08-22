From: Nicholas Miell <nmiell@comcast.net>
Subject: Re: [take12 0/3] kevent: Generic event handling mechanism.
Date: Tue, 22 Aug 2006 14:13:40 -0700
Message-ID: <1156281220.2476.65.camel@entropy>
References: <1156237191.8055.59.camel@entropy>
	 <Pine.LNX.4.64.0608221059030.26026@d.namei>
	 <1156276823.2476.22.camel@entropy>
	 <20060822.133606.48392664.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, johnpol@2ka.mipt.ru,
	linux-kernel@vger.kernel.org, drepper@redhat.com, akpm@osdl.org,
	netdev@vger.kernel.org, zach.brown@oracle.com, hch@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alnrmhc13.comcast.net ([204.127.225.93]:19949 "EHLO
	alnrmhc11.comcast.net") by vger.kernel.org with ESMTP
	id S1751272AbWHVVOX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 17:14:23 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060822.133606.48392664.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 13:36 -0700, David Miller wrote:
> From: Nicholas Miell <nmiell@comcast.net>
> Date: Tue, 22 Aug 2006 13:00:23 -0700
> 
> > I'm not the one proposing the new (potentially wrong) interface. The
> > onus isn't on me.
> 
> You can't demand a volunteer to do work, period.
> 
> If it matters to you, you have the option of doing the work.
> Otherwise you can't complain.

So if a volunteer does bad work, I'm obligated to accept it just because
I haven't done better?

Alternately, if a volunteer does bad work, must it be merged into the
kernel because there's isn't a better implementation? (I believe that
was tried at least once with devfs.)

And how is the quality of the work to be judged if the work isn't
commented, documented and explained, especially the userland-visible
parts that *cannot* *ever* *be* *changed* *or* *removed* once they're in
a stable kernel release?

-- 
Nicholas Miell <nmiell@comcast.net>

