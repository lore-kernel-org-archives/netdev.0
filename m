From: James Morris <jmorris@intercode.com.au>
Subject: Re: (usagi-users 02412) IPsec 2.5.70-bk9 and FreeS/WAN 1.99 with
 algopatches 0.8.1rc2
Date: Fri, 6 Jun 2003 00:25:58 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306060024330.2211-100000@excalibur.intercode.com.au>
References: <3525719.1054830009@[10.3.62.6]>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <usagi-users@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Dr. Peter Bieringer" <pb@bieringer.de>
In-Reply-To: <3525719.1054830009@[10.3.62.6]>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Jun 2003, Dr. Peter Bieringer wrote:

> Ohoh, sorry for confusions, my racoon here was a little bit buggy...
> 
> ...be warned, not using RHL's ipsec-tools from rawhide...looks like the 
> racoon isn't compiled in a proper environment :-( it doesn't support DES 
> and causes trouble on 3DES *grmml*).

Actually, the ABI changed recently, due to renumbering the algorithim ids 
in pfkeyv2.h.

(This will affect setkey as well).


- James
-- 
James Morris
<jmorris@intercode.com.au>
