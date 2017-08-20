From: Vallish Vaidyeshwara <vallish@amazon.com>
Subject: Re: [PATCH RESEND 0/2] enable hires timer to timeout datagram socket
Date: Sun, 20 Aug 2017 01:47:45 +0000
Message-ID: <20170820014744.GA43685@amazon.com>
References: <1503081850-10671-1-git-send-email-vallish@amazon.com>
 <20170818201854.xes246oviptinwvq@localhost>
 <20170818222756.GB28737@amazon.com>
 <20170819062145.vtr63ri4v577cymz@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <shuah@kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <eduval@amazon.com>, <anchalag@amazon.com>, <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170819062145.vtr63ri4v577cymz@localhost>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 19, 2017 at 08:21:45AM +0200, Richard Cochran wrote:
> On Fri, Aug 18, 2017 at 10:27:56PM +0000, Vallish Vaidyeshwara wrote:
> > We have a on-demand application that uses long timeouts and needs to react to
> > events within milliseconds.
>

Hello Richard,

> Huh?  The test program you posted does not react to any event.
>

Application has logic for complex events and test program is kept simple to
highlight the change in behavior seen with system calls.

Thanks.
-Vallish

> Thanks,
> Richard
> 
