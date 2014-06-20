From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] drivers/net/ethernet/broadcom/bnx2x/bnx2x_sriov.c:
 remove null test before kfree
Date: Thu, 19 Jun 2014 21:26:48 -0700 (PDT)
Message-ID: <20140619.212648.770824426892336652.davem@davemloft.net>
References: <1403033573-7754-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, ariele@broadcom.com,
	netdev@vger.kernel.org
To: fabf@skynet.be
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1403033573-7754-1-git-send-email-fabf@skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Fabian Frederick <fabf@skynet.be>
Date: Tue, 17 Jun 2014 21:32:53 +0200

> Fix checkpatch warning:
> WARNING: kfree(NULL) is safe this check is probably not required
> 
> Cc: Ariel Elior <ariele@broadcom.com>
> Cc: netdev@vger.kernel.org
> Signed-off-by: Fabian Frederick <fabf@skynet.be>

Applied.
