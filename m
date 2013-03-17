From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers: net: irda: use resource_size() in au1k_ir.c
Date: Sun, 17 Mar 2013 14:28:01 -0400 (EDT)
Message-ID: <20130317.142801.1476717176435086403.davem@davemloft.net>
References: <1363503826-24166-1-git-send-email-silviupopescu1990@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, samuel@sortiz.org,
	linux-kernel@vger.kernel.org
To: silviupopescu1990@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363503826-24166-1-git-send-email-silviupopescu1990@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>
Date: Sun, 17 Mar 2013 09:03:46 +0200

> This uses the resource_size() function instead of explicit computation.
> 
> Signed-off-by: Silviu-Mihai Popescu <silviupopescu1990@gmail.com>

Applied.
