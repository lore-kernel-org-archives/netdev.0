From: Andi Kleen <ak@suse.de>
Subject: Re: TX performance of Intel 82546
Date: Wed, 15 Sep 2004 16:55:03 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915145503.GE20509@wotan.suse.de>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org> <414808F3.70104@draigBrady.com> <1095250706.1057.214.camel@jzny.localdomain> <20040915140222.GD1274@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamal <hadi@cyberus.ca>, P@draigBrady.com,
        Linux NICS <linux.nics@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
Content-Disposition: inline
In-Reply-To: <20040915140222.GD1274@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, Sep 15, 2004 at 04:02:22PM +0200, Harald Welte wrote:
> On Wed, Sep 15, 2004 at 08:18:27AM -0400, jamal wrote:
> 
> > Our friends in FreeBSD claim they can do 1Mpps _forwarding_ with 
> > e1000 - forget about transmit only ;->
> 
> IMHO that was a 82547, attached to CSA and not PCI-X... 

Still only one e1000 can be attached to CSA. I didn't think
there are any that can do two. 

And routing only with a single NIC could be difficult... 

-Andi
