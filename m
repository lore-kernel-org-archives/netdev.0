From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Wed, 26 Feb 2003 00:47:26 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030226.004726.22558908.davem@redhat.com>
References: <20030225160634.A4525@infradead.org>
	<Pine.LNX.4.44.0302261926450.13739-100000@blackbird.intercode.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, yoshfuji@linux-ipv6.org, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
   usagi@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jmorris@intercode.com.au
In-Reply-To: <Pine.LNX.4.44.0302261926450.13739-100000@blackbird.intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: James Morris <jmorris@intercode.com.au>
   Date: Wed, 26 Feb 2003 19:33:18 +1100 (EST)

   On Tue, 25 Feb 2003, Christoph Hellwig wrote:
   
   > Also I really wonder whether we want to add just md5.c to 2.4 or
   > backport the cryptoapi core with md5 as the only algorithm so far..
   
   Any backport of new cryptoapi is likely to be some way off (after 2.6
   stabilizes), so the md5 module submitted for 2.4 is required for the time
   being.
   
This could be accelerated.
