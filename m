From: Brad Hards <bhards@bigpond.net.au>
Subject: Re: PF_PACKET??
Date: Fri, 19 Apr 2002 14:35:26 +1000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <200204191435.26210.bhards@bigpond.net.au>
References: <Pine.LNX.4.33L2.0204182324140.30494-100000@pali.cps.cmich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <linux-net-owner@vger.kernel.org>
To: Ish Rattan <ishwar@pali.cps.cmich.edu>, <linux-net@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.33L2.0204182324140.30494-100000@pali.cps.cmich.edu>
List-Id: netdev.vger.kernel.org

On Fri, 19 Apr 2002 13:27, Ish Rattan wrote:
> On Fri, 19 Apr 2002, Brad Hards wrote:
> > Why not use User-Mode Linux (http://user-mode-linux.sourceforge.net)?
> > You get the whole kernel, including the networking stack, running in
> > user-space. You can run several virtual machines on one real host, and
> > get to network between them in a couple of different ways. Might even be
> > worth doing if you had your own user-space implementation of the stack,
> > as the environment in which you run your implementation.
>
> If you have time can you give little more details on usage of UML for
> getting a user-mode TCP/IP stack?! I am fishing for more details. I plan
> to start on it after this semester is done (2 more weeks).
You should read the extensive, and quite good documentation on the web site. 
Understand that UML is a whole kernel, running as virtual machine, but as a 
userspace process.
I am not going to do the work for you :)

Brad
