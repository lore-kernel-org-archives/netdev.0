From: Eduardo Valentin <eduval@amazon.com>
Subject: Re: [PATCH v2 0/2] enable hires timer to timeout datagram socket
Date: Fri, 8 Sep 2017 11:55:21 -0700
Message-ID: <20170908185521.GA12340@u40b0340c692b58f6553c.ant.amazon.com>
References: <20170908170409.GA10020@u40b0340c692b58f6553c.ant.amazon.com>
 <20170908.101657.2131282706895004921.davem@davemloft.net>
 <1504891402.32080.5.camel@infradead.org>
 <20170908.102645.1086537961399780085.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <dwmw2@infradead.org>, <eduval@amazon.com>, <vallish@amazon.com>,
        <shuah@kernel.org>, <richardcochran@gmail.com>,
        <xiyou.wangcong@gmail.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <anchalag@amazon.com>,
        <dwmw@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170908.102645.1086537961399780085.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Fri, Sep 08, 2017 at 10:26:45AM -0700, David Miller wrote:
> From: David Woodhouse <dwmw2@infradead.org>
> Date: Fri, 08 Sep 2017 18:23:22 +0100
> 
> > I don't know that anyone's ever tried saying "show me the chapter and
> > verse of the documentation"
> 
> Do you know why I brought this up?  Because the person I am replying
> to told me that the syscall documentation should have suggested this
> or that.
> 
> That's why.

:-) My intention was for sure not to upset anybody.

Just to reiterate, the point of patch is simple, there was a change in behavior in the system call from one kernel version to the other. As I mentioned, I agree that the userspace could use other means to achieve the same, but still the system call behavior has changed.

> 
> So let's concentrate on the other aspects of my reply, ok?

I agree. I would prefer to understand here what is the technical reason not to accept these patches other than "use other system calls".


-- 
All the best,
Eduardo Valentin
