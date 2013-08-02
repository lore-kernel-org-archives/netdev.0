From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the driver-core tree with the
 net-next tree
Date: Fri, 2 Aug 2013 08:28:51 +0800
Message-ID: <20130802002851.GD11408@kroah.com>
References: <20130801152148.c98a281ec6e076646edeb7cb@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@resnulli.us>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130801152148.c98a281ec6e076646edeb7cb@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 01, 2013 at 03:21:48PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the driver-core tree got a conflict in
> net/core/net-sysfs.c between commit ff80e519ab1b ("net: export physical
> port id via sysfs") from the net-next tree and commit 6be8aeef348a ("net:
> core: convert class code to use dev_groups") from the driver-core tree.
> 
> I fixed it up (see below) and can carry the fix as necessary (no action
> is required).

Looks good to me, thanks.

greg k-h
