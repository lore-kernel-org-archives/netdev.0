From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Fri, 18 Oct 2002 20:29:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021019032907.GC12716@kroah.com>
References: <4301.1034994787@ocs3.intra.ocs.com.au> <4914.1034996075@ocs3.intra.ocs.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Keith Owens <kaos@ocs.com.au>
Content-Disposition: inline
In-Reply-To: <4914.1034996075@ocs3.intra.ocs.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Oct 19, 2002 at 12:54:35PM +1000, Keith Owens wrote:
> Not that it makes any difference, there has to be a way to make that
> size 0 when LSM is compiled off.

Already done, see the patches sent to lkml yesterday :)

thanks,

greg k-h
