From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the staging tree with the net tree
Date: Thu, 25 Aug 2011 21:33:57 -0700
Message-ID: <20110826043357.GA17686@kroah.com>
References: <20110826134705.0d5b6767777f0af2f8667731@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Larry Finger <Larry.Finger@lwfinger.net>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110826134705.0d5b6767777f0af2f8667731@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Aug 26, 2011 at 01:47:05PM +1000, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the staging tree got a conflict in
> drivers/staging/rtl8192e/r8192E_core.c between commit afc4b13df143 ("net:
> remove use of ndo_set_multicast_list in drivers") from the net tree and
> commit 09505184ec3d ("staging: rtl8192e: Remove files that are not used")
> from the staging tree.
> 
> The latter removed the file, so I did that.

Thanks, that should be the correct thing :)

greg k-h
