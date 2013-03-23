From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH] net: Add support for handling queueing in hardware
Date: Sat, 23 Mar 2013 12:02:21 -0700
Message-ID: <20130323190221.GA22005@roeck-us.net>
References: <E1UJ1fR-0004hs-4l@swissweb.swissdisk.com>
 <20130322.101139.1942128058226201237.davem@davemloft.net>
 <A5ACC15C-361D-48E6-BFFF-9AA3966C2A68@freescale.com>
 <20130322.103302.1277256650283142022.davem@davemloft.net>
 <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, afleming@freescale.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ben Collins <benmcollins13@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <FE78128C-01DB-4831-ACBE-BA3E3A428BFC@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Mar 22, 2013 at 10:43:44AM -0400, Ben Collins wrote:
> On Mar 22, 2013, at 10:33 AM, David Miller <davem@davemloft.net> wrote:
> 
> > From: Fleming Andy-AFLEMING <afleming@freescale.com>
> > Date: Fri, 22 Mar 2013 14:31:50 +0000
> > 
> >> It would appear one of our customers is attempting to upstream our
> >> code for us. We are aware that this current solution is unacceptable
> >> (which is why we have not submitted it), and we are currently trying
> >> to develop a less hacky solution that integrates with qdisc.
> > 
> > Ben, can can you coordinate with people instead of doing crap like
> > this?
> 
> 
> "For us" is a loose term, when it's more that we are attempting to upstream code so our system is supported by a mainline kernel instead of having one-off kernels.
> 
> And we have been talking with Freescale about this for quite some time (couple years?). They have a roadmap that doesn't include getting this driver supported in mainline any time soon, so I'm taking time to get this done for our own system. I'm not meaning to step on any toes.
> 
How true. You are not the only one with thatt problem.

Ben, can you possibly send me your complete patch set on top of 3.8, or point me
to a git tree ?

I have exactly the same problem, I need the code in 3.8, it doesn't seem
like the Freescale code will show up anytime soon, and I don't seem to be able
to get early code for testing either. I can promise you a free test coverage
and bug fixing ...

Thanks,
Guenter
