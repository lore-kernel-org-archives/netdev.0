From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: recommendations for NIC HW(/SW) design?
Date: Tue, 28 Sep 2004 10:12:42 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928081242.GB6886@xi.wantstofly.org>
References: <20040926152955.GD17043@xi.wantstofly.org> <20040927155144.GU3236@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@gnumonks.org>
Content-Disposition: inline
In-Reply-To: <20040927155144.GU3236@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Sep 27, 2004 at 05:51:44PM +0200, Harald Welte wrote:

> > (Since the Intel IXP processor is just an ARM processor with a network
> > interface grafted onto the chip, a bunch of things that apply to PCI
> > NIC design might not apply here.)
> 
> I think this IXP is only a UP architecture, is it?

Yeah, it's a single-core ARM with a big fat pipe (either 4 or 10 Gb/s
depending on model) grafted onto the CPU.


--L
