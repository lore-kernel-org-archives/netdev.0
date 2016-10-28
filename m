From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] LSO feature added to Cadence GEM driver
Date: Fri, 28 Oct 2016 13:49:36 -0400 (EDT)
Message-ID: <20161028.134936.1247072115293393188.davem@davemloft.net>
References: <1477315088-28396-1-git-send-email-rafalo@cadence.com>
        <1477397130-24250-1-git-send-email-rafalo@cadence.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, eric.dumazet@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: rafalo@cadence.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1477397130-24250-1-git-send-email-rafalo@cadence.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Rafal Ozieblo <rafalo@cadence.com>
Date: Tue, 25 Oct 2016 13:05:30 +0100

> New Cadence GEM hardware support Large Segment Offload (LSO):
> TCP segmentation offload (TSO) as well as UDP fragmentation
> offload (UFO). Support for those features was added to the driver.
> 
> Signed-off-by: Rafal Ozieblo <rafalo@cadence.com>

Patch does not apply cleanly to net-next, please respin.

Also please fix your Subject line, it should be of the form:

	[PATCH net-next v2] cadence: Add LSO support.
