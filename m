From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Request for an ARPHRD_
Date: Mon, 24 Oct 2005 23:51:40 +0200
Message-ID: <20051024215140.GA10872@xi.wantstofly.org>
References: <200510240255.28416.daniele@orlandi.com> <200510241807.23290.ak@suse.de> <200510242333.05366.daniele@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Daniele Orlandi <daniele@orlandi.com>
Content-Disposition: inline
In-Reply-To: <200510242333.05366.daniele@orlandi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Oct 24, 2005 at 11:33:04PM +0200, Daniele Orlandi wrote:

> My main concern is that without an ARPHRD_ constant guaranteed to be
> unique I wouldn't be able to propose a patch for libpcap people to map
> the (already allocated) DLT_ to the correct ARPHRD_.

First get your code in the kernel, then submit the patch to libpcap.


--L
