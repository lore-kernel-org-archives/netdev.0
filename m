From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] drivers/net/bnx2x: use ARRAY_SIZE macro in
 bnx2x_main.c
Date: Thu, 09 Sep 2010 21:56:24 -0700 (PDT)
Message-ID: <20100909.215624.45886987.davem@davemloft.net>
References: <1283979457-4649-1-git-send-email-nikitasangelinas@gmail.com>
	<1283980837-5025-1-git-send-email-nikitasangelinas@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, dmitry@broadcom.com, yanivr@broadcom.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nikitasangelinas@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283980837-5025-1-git-send-email-nikitasangelinas@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nikitas Angelinas <nikitasangelinas@gmail.com>
Date: Wed,  8 Sep 2010 22:20:37 +0100

> Replace sizeof(bnx2x_parity_mask)/(sizeof(bnx2x_parity_mask[0]) with
> ARRAY_SIZE(bnx2x_parity_mask) in drivers/net/bnx2x/bnx2x_main.c
> 
> Signed-off-by: Nikitas Angelinas <nikitasangelinas@gmail.com>

Applied, thank you.
