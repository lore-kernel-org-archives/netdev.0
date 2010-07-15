From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Net: ethernet: pe2.c: fix EXPORT_SYMBOL macro code
 style issue
Date: Wed, 14 Jul 2010 18:27:19 -0700 (PDT)
Message-ID: <20100714.182719.260098958.davem@davemloft.net>
References: <1279139074-13040-1-git-send-email-chihau@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chihau@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1279139074-13040-1-git-send-email-chihau@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chihau Chau <chihau@gmail.com>
Date: Wed, 14 Jul 2010 16:24:34 -0400

> From: Chihau Chau <chihau@gmail.com>
> 
> This patch fix a code style issuei, if a function is exported, the
> EXPORT_SYMBOL macro for it should follow immediately after the closing
> function brace line.
> 
> Signed-off-by: Chihau Chau <chihau@gmail.com>

Applied.
