From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH 3/3][bonding 2.4] Add VLAN support in ALB mode
Date: Thu, 19 Feb 2004 10:44:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040219104425.7d708bee.davem@redhat.com>
References: <200402191216.15820.shmulik.hen@intel.com>
	<20040219102025.3d485145.davem@redhat.com>
	<4035002C.3070509@pobox.com>
	<40350064.2020504@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shmulik.hen@intel.com, netdev@oss.sgi.com,
        bonding-devel@lists.sourceforge.net
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <40350064.2020504@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 19 Feb 2004 13:28:52 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> un-ACK.
> 
> These patches also depend on bonding cleanup patches not yet in 2.4.
> 
> Apply all but these 3, and I will take care of them.

Ok, the be clear, I'll toss the ARP + 8021Q infrastructure patches
to Marcelo and you'll take care of the rest.
