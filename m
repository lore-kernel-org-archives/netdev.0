From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] netfilter: fix connlimit Kconfig prompt string
Date: Thu, 14 Nov 2013 00:12:09 +0100
Message-ID: <20131113231209.GA4552@localhost>
References: <527B29A6.6090802@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, lailavrazda1979@gmail.com
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <527B29A6.6090802@infradead.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 06, 2013 at 09:48:22PM -0800, Randy Dunlap wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> 
> Under Core Netfilter Configuration, connlimit match support has
> an extra double quote at the end of it.
> 
> Fixes a portion of kernel bugzilla #52671:
>   https://bugzilla.kernel.org/show_bug.cgi?id=52671

Applied, thanks Randy.
