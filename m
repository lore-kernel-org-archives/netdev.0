From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tg3: Add read dma workaround for 5720
Date: Tue, 04 Jun 2013 17:25:53 -0700 (PDT)
Message-ID: <20130604.172553.291812130615333546.davem@davemloft.net>
References: <1370287174-11308-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roland@purestorage.com,
	stable@vger.kernel.org, mchan@broadcom.com
To: nsujir@broadcom.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1370287174-11308-1-git-send-email-nsujir@broadcom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Mon, 3 Jun 2013 12:19:34 -0700

> Commit 091f0ea30074bc43f9250961b3247af713024bc6 "tg3: Add New 5719 Read
> DMA workaround" added a workaround for TX DMA stall on the 5719. This
> workaround needs to be applied to the 5720 as well.
> 
> Cc: stable@vger.kernel.org
> Reported-by: Roland Dreier <roland@purestorage.com>
> Tested-by: Roland Dreier <roland@purestorage.com>
> Signed-off-by: Nithin Nayak Sujir <nsujir@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks.
