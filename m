From: Daniele Orlandi <daniele@orlandi.com>
Subject: Re: Request for an ARPHRD_
Date: Tue, 25 Oct 2005 00:08:09 +0200
Message-ID: <200510250008.10409.daniele@orlandi.com>
References: <200510240255.28416.daniele@orlandi.com> <200510242333.05366.daniele@orlandi.com> <20051024215140.GA10872@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@vger.kernel.org
In-Reply-To: <20051024215140.GA10872@xi.wantstofly.org>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Monday 24 October 2005 23:51, Lennert Buytenhek wrote:
>
> First get your code in the kernel, then submit the patch to libpcap.

Hopefully I will but currently vISDN is not mature enough to be evaluated for 
kernel inclusion.

I would like to keep it out of the tree while it matures, however I would also 
like to avoid potential constants clashes with outher/future code.

You may see the constants allocation as the first step to include that code in 
the kernel.

Bye,

-- 
  Daniele Orlandi
