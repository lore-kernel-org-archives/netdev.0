From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH V2 -next] netfilter: Use LOGLEVEL_<FOO> defines
Date: Wed, 25 Mar 2015 12:19:32 +0100
Message-ID: <20150325111932.GA6546@salvia>
References: <20150323140841.0b807b95@canb.auug.org.au>
 <20150323124723.GA6740@salvia>
 <1427115331.16851.11.camel@perches.com>
 <20150323130638.GA6857@salvia>
 <1427117031.16851.16.camel@perches.com>
 <20150324003828.0eac53d9@canb.auug.org.au>
 <20150323135235.GA7595@salvia>
 <1427136610.16851.29.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1427136610.16851.29.camel@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Mar 23, 2015 at 11:50:10AM -0700, Joe Perches wrote:
> Use the #defines where appropriate.
> 
> Miscellanea:
> 
> Add explicit #include <linux/kernel.h> where it was not
> previously used so that these #defines are a bit more
> explicitly defined instead of indirectly included via:
> 	module.h->moduleparam.h->kernel.h

Applied, thanks.
