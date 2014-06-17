From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] slcan: Port write_wakeup deadlock fix from slip
Date: Mon, 16 Jun 2014 21:30:03 -0700 (PDT)
Message-ID: <20140616.213003.1138477495538114124.davem@davemloft.net>
References: <1402885397-21062-1-git-send-email-tylerwhall@gmail.com>
	<1402885397-21062-2-git-send-email-tylerwhall@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan@hartkopp.net, nautsch2@gmail.com,
	linux-kernel@vger.kernel.org
To: tylerwhall@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402885397-21062-2-git-send-email-tylerwhall@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tyler Hall <tylerwhall@gmail.com>
Date: Sun, 15 Jun 2014 22:23:17 -0400

> The commit "slip: Fix deadlock in write_wakeup" fixes a deadlock caused
> by a change made in both slcan and slip. This is a direct port of that
> fix.
> 
> Signed-off-by: Tyler Hall <tylerwhall@gmail.com>

Applied and queued up for -stable.
