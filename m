From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] drivers/net: sgiseeq: fix return on error
Date: Tue, 26 Oct 2010 10:02:23 -0700 (PDT)
Message-ID: <20101026.100223.48514032.davem@davemloft.net>
References: <20101026184505.077246a2@absol.kitzblitz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nikai@nikai.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20101026184505.077246a2@absol.kitzblitz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Nicolas Kaiser <nikai@nikai.net>
Date: Tue, 26 Oct 2010 18:45:05 +0200

> If we continue on error, we'd likely free the IRQ that we
> didn't get, right?
> 
> Signed-off-by: Nicolas Kaiser <nikai@nikai.net>

Yep, applied, thank you.
