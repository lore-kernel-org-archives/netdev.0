From: Greg KH <greg@kroah.com>
Subject: Re: Recent wireless breakage (ipw2200, iwconfig, NetworkManager)
Date: Mon, 5 Mar 2007 17:17:09 -0800
Message-ID: <20070306011709.GA13667@kroah.com>
References: <20070305011625.GA7681@kroah.com> <20070305064229.GJ23311@waste.org> <20070305070248.GA30699@kroah.com> <20070305071325.GK23311@waste.org> <20070305154609.GA3626@irc.pl> <20070305211425.GR16722@waste.org> <20070306002457.GA7078@brong.net> <20070306003715.GA12566@kroah.com> <20070306005625.GC19634@thunk.org> <20070305170849.c042e802.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Theodore Tso <tytso@mit.edu>, Bron Gondwana <brong@fastmail.fm>,
	Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yi.zhu@intel.com, jketreno@linux.intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:37846 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932839AbXCFBSo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Mar 2007 20:18:44 -0500
Content-Disposition: inline
In-Reply-To: <20070305170849.c042e802.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 05, 2007 at 05:08:49PM -0800, Andrew Morton wrote:
> On Mon, 5 Mar 2007 19:56:25 -0500
> Theodore Tso <tytso@mit.edu> wrote:
> 
> > So the question really is are we really done making changes to sysfs,
> > or maybe what we should do is talk about major version numbers to
> > sysfs.
> 
> Perhaps using a config option wasn't the right way to do this - a kernel
> boot parameter might be better.

Ok, I have no problem with that if people really want it.  But give me
the option to also make it a config option so I don't have to change our
bootloaders too.

Does that sound acceptable?

thanks,

greg k-h
