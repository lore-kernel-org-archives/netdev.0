From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH]  [ATM]: [fore200e] rewrite to eliminate
 pci_find_device() but preserve sbus support
Date: Thu, 10 Mar 2005 19:40:55 -0800
Message-ID: <20050310194055.3b5baac6.davem@davemloft.net>
References: <200502231417.j1NEHIZ2012625@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200502231417.j1NEHIZ2012625@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 23 Feb 2005 09:17:18 -0500
"chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil> wrote:

> this patch correctly removes the pci_find_device() used by the fore200e
> driver.  the __init/__exit remains a bit clunky since we need to preserve
> sbus support.
> 
> please apply to 2.6.

Applied, thanks Chas.
