From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] remove bogus exports in ppp
Date: Thu, 27 Jan 2005 15:42:46 -0800
Message-ID: <20050127154246.3e4c26e6.davem@davemloft.net>
References: <16889.31219.724098.168789@cargo.ozlabs.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, hch@lst.de, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Mackerras <paulus@samba.org>
In-Reply-To: <16889.31219.724098.168789@cargo.ozlabs.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 28 Jan 2005 10:32:03 +1100
Paul Mackerras <paulus@samba.org> wrote:

> Remove unnecessary exports from ppp_generic.c.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Signed-off-by: Paul Mackerras <paulus@samba.org>

How likely is it that anything in the world makes any
reference to this thing outside of the kernel tree?
