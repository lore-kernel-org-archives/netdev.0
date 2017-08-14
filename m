From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] qlge: fix duplicated code for different branches
Date: Mon, 14 Aug 2017 10:58:22 -0700 (PDT)
Message-ID: <20170814.105822.1041966314212473836.davem@davemloft.net>
References: <20170813015840.GA8443@embeddedgus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: harish.patil@cavium.com, manish.chopra@cavium.com,
        Dept-GELinuxNICDev@cavium.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: gustavo@embeddedor.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170813015840.GA8443@embeddedgus>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Date: Sat, 12 Aug 2017 20:58:40 -0500

> Refactor code in order to avoid identical code for different branches.
> 
> This issue was detected with the help of Coccinelle.
> 
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Applied.
