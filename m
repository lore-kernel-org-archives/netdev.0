From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/Makefile: remove CONFIG_AVERAGE build rule
Date: Wed, 26 Aug 2015 10:54:10 -0700 (PDT)
Message-ID: <20150826.105410.311971937080754551.davem@davemloft.net>
References: <20150826133612.GA31643@faui49jenkins20.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes.berg@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: valentinrothberg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150826133612.GA31643@faui49jenkins20.informatik.uni-erlangen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Valentin Rothberg <valentinrothberg@gmail.com>
Date: Wed, 26 Aug 2015 15:36:12 +0200

> The Kconfig option AVERAGE and its implementation has been removed by
> commit f4e774f55fe0 ("average: remove out-of-line implementation").
> Remove the dead build rule in lib/Makefile.
> 
> Signed-off-by: Valentin Rothberg <valentinrothberg@gmail.com>
> Reviewed-by: Johannes Berg <johannes@sipsolutions.net>

Applied, thanks.
