From: James Morris <jmorris@intercode.com.au>
Subject: Re: IPsec 2.5.70-bk9 and FreeS/WAN 1.99 with algopatches 0.8.1rc2
 (in)compatible encryption methods
Date: Fri, 6 Jun 2003 00:16:02 +1000 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Mutt.LNX.4.44.0306060014090.2173-100000@excalibur.intercode.com.au>
References: <35410000.1054818456@klopffest.muc.aerasec.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, <usagi-users@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Dr. Peter Bieringer" <pb@bieringer.de>
In-Reply-To: <35410000.1054818456@klopffest.muc.aerasec.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 5 Jun 2003, Dr. Peter Bieringer wrote:

> I'm very wondering why 3DES is incompatible in IPsec-SA modus, while 
> working in IKE.

What happens if you use manual configurations (e.g. setkey with the native 
ipsec) ?

With this, we can first establish whether on the wire stuff is 
fundamentally working, before looking at negotiated configurations.


- James
-- 
James Morris
<jmorris@intercode.com.au>
