From: jamal <hadi@cyberus.ca>
Subject: Re: TX performance of Intel 82546
Date: 15 Sep 2004 10:46:14 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095259574.1032.42.camel@jzny.localdomain>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	 <414808F3.70104@draigBrady.com>
	 <1095250706.1057.214.camel@jzny.localdomain>
	 <20040915140222.GD1274@sunbeam.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linux NICS <linux.nics@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20040915140222.GD1274@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 2004-09-15 at 10:02, Harald Welte wrote:
> On Wed, Sep 15, 2004 at 08:18:27AM -0400, jamal wrote:
> 
> > Our friends in FreeBSD claim they can do 1Mpps _forwarding_ with 
> > e1000 - forget about transmit only ;->
> 
> IMHO that was a 82547, attached to CSA and not PCI-X... 

I thought PCI-X should have less overhead in this case (because it has
split-transaction capability), no?
What do you mean by above statement of it not being PCI-X?

cheers,
jama
