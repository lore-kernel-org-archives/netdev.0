From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Very strange Marvell/Yukon Gigabit NIC networking problems
Date: Thu, 1 Sep 2005 10:59:50 -0700
Message-ID: <20050901105950.6766e299@dxpl.pdx.osdl.net>
References: <20050830152908.1dc24339@dxpl.pdx.osdl.net>
	<20050831000948.40799.qmail@web53607.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Daniel Drake <dsd@gentoo.org>, Steve Kieu <haiquy@yahoo.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030271AbVIAR7j@vger.kernel.org>
To: Steve Kieu <haiquy@yahoo.com>
In-Reply-To: <20050831000948.40799.qmail@web53607.mail.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Aug 2005 10:09:48 +1000 (EST)
Steve Kieu <haiquy@yahoo.com> wrote:

> 
> --- Stephen Hemminger <shemminger@osdl.org> wrote:
> 
> > On Wed, 31 Aug 2005 07:49:37 +1000 (EST)
> 
> > > 
> > > install-8_23.tar.bz2
> > 
> > Just look for references to CHIP_REV_YU_LITE_A3 in
> > the driver
> > 	sk98lin/skgeinit.c and sk98lin/skxmac2.c
> > The comparison should always be:
> 
> Have a look but no clue to patch it, there are one
> instance of comparing

I don't fix the out of tree vendor driver. sorry.
