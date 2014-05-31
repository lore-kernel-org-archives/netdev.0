From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TRIVIAL] atm: remove commented out check
Date: Fri, 30 May 2014 17:17:22 -0700 (PDT)
Message-ID: <20140530.171722.342011579545846279.davem@davemloft.net>
References: <1401203232.28714.10.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401203232.28714.10.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 27 May 2014 17:07:12 +0200

> This preprocessor check is commented out ever since this file was added
> during the v2.3 development cycle. It is unclear what it purpose might
> have been. Whatever it was, it can safely be removed now.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>
> ---
> Compile tested.
> 
> Perhaps someone on netdev knows what CONFIG_SINGLE_SIGITF might have
> been for. Not that it actually matters.

Yeah it can't actually matter, applied to net-next, thanks.
