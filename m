From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [2.6 patch] drivers/net/ixgb/: possible cleanups
Date: Sat, 7 May 2005 13:40:41 +0100
Message-ID: <20050507124041.GA22088@infradead.org>
References: <20050506211834.GM3590@stusta.de> <5fc59ff3050506153523cd12dd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, ayyappan.veeraiyan@intel.com,
        ganesh.venkatesan@intel.com, john.ronciak@intel.com, jgarzik@pobox.com,
        netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Content-Disposition: inline
In-Reply-To: <5fc59ff3050506153523cd12dd@mail.gmail.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, May 06, 2005 at 03:35:52PM -0700, Ganesh Venkatesan wrote:
> Adrian:
> 
> Some of your suggestions are already part of the driver we are
> currently testing. This was based partly on your Feb '05 patch. We
> will not be able to apply your patch as is since some of the changes
> are in part of code that is shared with other drivers that are not
> GPLd.

I don't think Adrian can claim copyright on code removal even if he
wanted to (which I doubt :))
