From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH REPOST 2.6.11-rc4-netdev1] bonding: don't drop non-VLAN
 traffic
Date: Thu, 03 Mar 2005 18:37:26 -0500
Message-ID: <42279FB6.6090105@pobox.com>
References: <200503032333.j23NXBh3017684@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Olaf Kirch <okir@suse.de>
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200503032333.j23NXBh3017684@death.nxdomain.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> 	Change the bonding driver to not drop non-VLAN traffic when a
> VLAN is configured above it.  Originally fixed by Olaf Kirch
> <okir@suse.de>; I changed his patch slightly to update comments.

Does this go on top of, or underneath, your pile of bonding patches that 
I merged into netdev-2.6?

	Jeff
