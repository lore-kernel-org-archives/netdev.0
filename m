From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] arcnet: remove check for CONFIG_SA1100_CT6001
Date: Fri, 30 May 2014 17:21:09 -0700 (PDT)
Message-ID: <20140530.172109.1758735676902083194.davem@davemloft.net>
References: <1401220424.28714.17.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1401220424.28714.17.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 27 May 2014 21:53:44 +0200

> A check for CONFIG_SA1100_CT6001 was added in v2.6.11. But the related
> Kconfig symbol was never added to the tree. Remove this check and do
> some related cleaning up.
> 
> Signed-off-by: Paul Bolle <pebolle@tiscali.nl>

Applied to net-next, thanks.
