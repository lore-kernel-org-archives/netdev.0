From: Greg KH <greg@kroah.com>
Subject: Re: linux-next: manual merge of the driver-core tree with the
 net-next tree
Date: Sun, 3 Feb 2013 20:59:14 -0800
Message-ID: <20130204045914.GA16842@kroah.com>
References: <20130204153831.083f30730888d66d4f83acd3@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Kees Cook <keescook@chromium.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130204153831.083f30730888d66d4f83acd3@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 04, 2013 at 03:38:31PM +1100, Stephen Rothwell wrote:
> Hi Greg,
> 
> Today's linux-next merge of the driver-core tree got a conflict in drivers/net/wan/Kconfig between commit a786a7c0ad44 ("wanrouter: completely decouple obsolete code from kernel") from the net-next tree and commit c9f1b39aee74 ("drivers/net/wan: remove depends on CONFIG_EXPERIMENTAL") from the driver-core tree.
> 
> The former removed part of the text changed by the latter, so I just did
> that (see below) and can carry the fix as necessary (no action is
> required).

That sounds fine to me, thanks.

greg k-h
