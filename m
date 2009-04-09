From: Matt Mackall <mpm@selenic.com>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Thu, 09 Apr 2009 10:00:59 -0700
Message-ID: <1239296459.31467.142.camel@calx>
References: <200904061430.26276.rgetz@blackfin.uclinux.org>
	 <200904071744.17727.rgetz@blackfin.uclinux.org>
	 <1239220294.31467.55.camel@calx>
	 <200904090954.54601.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Chris Peterson <cpeterso@cpeterso.com>
To: Robin Getz <rgetz@blackfin.uclinux.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936064AbZDITDy@vger.kernel.org>
In-Reply-To: <200904090954.54601.rgetz@blackfin.uclinux.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2009-04-09 at 09:54 -0400, Robin Getz wrote:
> On Wed 8 Apr 2009 15:51, Matt Mackall pondered:
> > On Tue, 2009-04-07 at 17:44 -0400, Robin Getz wrote:
> > > Is that "Everything in general, with a few exceptions", or
> > > "__Everything__"?
> > 
> > Everything. We want every input point to better document the type of
> > entropy source.
> 
> OK - any objections to something like this?

Hmm, this is a purely internal interface. Not sure if we need to bother
with scheduling it. My plan was to simply get the new code in and sweep
the kernel. 

-- 
http://selenic.com : development and support for Mercurial and Linux
