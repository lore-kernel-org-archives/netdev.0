From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/2] net-next: mediatek: bring up QDMA RX ring 0
Date: Wed, 09 Aug 2017 22:47:08 -0700 (PDT)
Message-ID: <20170809.224708.2158045350450030076.davem@davemloft.net>
References: <20170809100932.10539-1-john@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sean.wang@mediatek.com, netdev@vger.kernel.org,
        linux-mediatek@lists.infradead.org, linux-kernel@vger.kernel.org,
        muciri@openmesh.com, shashidhar.lakkavalli@openmesh.com
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809100932.10539-1-john@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Wed,  9 Aug 2017 12:09:30 +0200

> The MT7623 has several DMA rings. Inside the SW path, the core will use
> the PDMA when receiving traffic. While bringing up the HW path we noticed
> that the PPE requires the QDMA RX to also be brought up as it uses this
> ring internally for its flow scheduling.

Series applied.
