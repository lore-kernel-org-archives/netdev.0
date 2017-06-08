From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the net tree
Date: Wed, 07 Jun 2017 20:17:57 -0400 (EDT)
Message-ID: <20170607.201757.1253550817745426205.davem@davemloft.net>
References: <20170608100858.4c1b18db@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, hdegoede@redhat.com,
        gregkh@linuxfoundation.org
To: sfr@canb.auug.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608100858.4c1b18db@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 8 Jun 2017 10:08:58 +1000

> I applied the following merge fix patch for today.
> 
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Thu, 8 Jun 2017 09:49:26 +1000
> Subject: [PATCH] net: fix up for "Fix inconsistent teardown and release of private netdev state"
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Looks good to me, thanks Stephen.
