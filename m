From: Jean Tourrilhes <jt@bougret.hpl.hp.com>
Subject: Re: linux/802_11.h header
Date: Tue, 30 Mar 2004 15:39:34 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040330233934.GA16711@bougret.hpl.hp.com>
References: <Pine.LNX.4.58.0403301514080.7498@marabou.research.att.com> <20040330215128.GA13891@bougret.hpl.hp.com> <Pine.LNX.4.58.0403301820001.8684@marabou.research.att.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pavel Roskin <proski@gnu.org>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0403301820001.8684@marabou.research.att.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 30, 2004 at 06:23:46PM -0500, Pavel Roskin wrote:
> On Tue, 30 Mar 2004, Jean Tourrilhes wrote:
> 
> > > Does anybody know who wrote 802_11.h, whether it's deprecated, and if not,
> > > why it's not used?
> >
> > 	Why don't you ask Simon directly ?
> 
> Because my question is not why atmel_cs uses a header it doesn't need
> (the answer would be likely "oops" or "just in case").
> 
> My question is why we have two headers for the same purpose in the kernel
> and what are we going to do with the header that is not used.

	At some point, we had the headers of the old aironet4500
driver which looked like this one, but I don't think this driver was
ever moved to the wireless directory, so this is why I think this file
was added with the Atmel driver.

> Pavel Roskin

	Jean
