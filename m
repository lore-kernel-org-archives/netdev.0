From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] ethtool_ops rev 4
Date: Fri, 1 Aug 2003 16:01:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030801160136.3342c5cc.davem@redhat.com>
References: <20030801150232.GV22222@parcelfarce.linux.theplanet.co.uk>
	<20030801154021.GA7696@gtf.org>
	<20030801154656.GW22222@parcelfarce.linux.theplanet.co.uk>
	<20030801162536.GA18574@gtf.org>
	<20030801132037.3f3542ae.davem@redhat.com>
	<3F2AE91D.5090705@pobox.com>
	<20030801153255.204baf66.davem@redhat.com>
	<3F2AF141.2010308@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: willy@debian.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <3F2AF141.2010308@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 01 Aug 2003 19:01:21 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> A DO_ETHTOOL_OPS macro in the driver's ->do_ioctl -- intentionally not 
> included in the kernel -- does the rest,

I don't understand.

Where does this DO_ETHTOOL_OPS macro come from?  Is it defined
by kcompat?  If so, how will drivers in vanilla 2.4.x trees end
up with the DO_ETHTOOL_OPS define?
