From: jamal <hadi@cyberus.ca>
Subject: Re: [Bonding-devel] Re: [SET 2][PATCH 2/8][bonding] Propagating
	master'ssettings toslaves
Date: 11 Aug 2003 22:32:59 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1060655579.1027.51.camel@jzny.localdomain>
References: <E791C176A6139242A988ABA8B3D9B38A014C9474@hasmsx403.iil.intel.com>
	 <200308111720.38472.shmulik.hen@intel.com>
	 <1060612481.1034.15.camel@jzny.localdomain>
	 <200308111925.38278.shmulik.hen@intel.com> <3F37C7C3.7070807@pobox.com>
	 <3F37D2ED.B4B9223C@thalesatm.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, shmulik.hen@intel.com,
   bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Laurent DENIEL <laurent.deniel@thalesatm.com>
In-Reply-To: <3F37D2ED.B4B9223C@thalesatm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2003-08-11 at 13:31, Laurent DENIEL wrote:

> But I agree that it is interesting to do some stuff at user land, and if 
> the bonding had an option to disable the automatic failover policy, 
> this could be implemented with trigger towards user land application that 
> could use an ioctl call to switch to the appropriate NIC according to

You spoilt otherwise sane text by mentioning ioctl;-> 

> But the fast and simple failover policy shall remain in kernel code.

nod from here. Simple failover policies should stay in the kernel.

cheers,
jamal
