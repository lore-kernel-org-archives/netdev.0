From: James Morris <jmorris@intercode.com.au>
Subject: RE: [PATCH] convering bonding driver /proc interface to seq_file
Date: Mon, 25 Aug 2003 01:15:13 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0308250112470.21951-100000@excalibur.intercode.com.au>
References: <E791C176A6139242A988ABA8B3D9B38A014C94C0@hasmsx403.iil.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@osdl.org>,
   Chad Tindel <ctindel@users.sourceforge.net>,
   Jay Vosburgh <fubar@us.ibm.com>, "David S. Miller" <davem@redhat.com>,
   Jeff Garzik <jgarzik@pobox.com>, <bonding-devel@lists.sourceforge.net>,
   <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Hen, Shmulik" <shmulik.hen@intel.com>
In-Reply-To: <E791C176A6139242A988ABA8B3D9B38A014C94C0@hasmsx403.iil.intel.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 23 Aug 2003, Hen, Shmulik wrote:

> Also, instead of using a seq_file interface and using a
> pointer to skip to the relevant part, we've used a different
> proc creation interface that allows passing a pointer to bond
> and thus retrieve just the relevant bond device's data.

Can you provide a pointer to this code?

seq_file is the standard and preferred way to do this kind of thing.


- James
-- 
James Morris
<jmorris@intercode.com.au>
