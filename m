From: James Morris <jmorris@intercode.com.au>
Subject: Re: [PATCH] IPv6: Privacy Extensions for Stateless Address
 Autoconfiguration in IPv6
Date: Wed, 26 Feb 2003 19:33:18 +1100 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0302261926450.13739-100000@blackbird.intercode.com.au>
References: <20030225160634.A4525@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "YOSHIFUJI Hideaki / ?$B5HF#1QL@?(B" <yoshfuji@linux-ipv6.org>,
   <davem@redhat.com>, <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>,
   <kuznet@ms2.inr.ac.ru>, <pekkas@netcore.fi>, <usagi@linux-ipv6.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Christoph Hellwig <hch@infradead.org>
In-Reply-To: <20030225160634.A4525@infradead.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 25 Feb 2003, Christoph Hellwig wrote:

> Also I really wonder whether we want to add just md5.c to 2.4 or
> backport the cryptoapi core with md5 as the only algorithm so far..

Any backport of new cryptoapi is likely to be some way off (after 2.6
stabilizes), so the md5 module submitted for 2.4 is required for the time
being.


- James
-- 
James Morris
<jmorris@intercode.com.au>
