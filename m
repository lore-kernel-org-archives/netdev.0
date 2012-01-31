From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] linux-next: et131x: Fixups due to merge issues from
 staging tree
Date: Tue, 31 Jan 2012 10:26:09 -0800
Message-ID: <20120131182609.GA12819@kroah.com>
References: <20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au>
 <20111025121551.GA2108@marke.airties>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Mark Einon <mark.einon@gmail.com>
To: 20111025192636.f816c8860ee168a0a4756eda@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20111025121551.GA2108@marke.airties>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 25, 2011 at 01:15:52PM +0100, Mark Einon wrote:
> 
> Manually merged changes from commits afc4b13df143, bf3f1a6081aa and 5d6bcdfe38ce into et131x.c as identified in email below.
> 
> Also removed dependency on NETDEV_1000 in Kconfig, which no longer exists.
> 
> Greg: This patch should also be good for the staging tree.

I don't think this is needed anymore, right?

If so, please redo it against Linus's tree and send it to me.

thanks,

greg k-h
