From: Timur Tabi <timur@tabi.org>
Subject: Re: [PATCH 1/2] net/fsl_pq_mdio: check TBI address for consistency
 with mapped range
Date: Sun, 11 Oct 2015 07:41:52 -0500
Message-ID: <561A5910.1070202@tabi.org>
References: <1371041258-15298-1-git-send-email-ogabbay@advaoptical.com>
 <1444403708-16576-1-git-send-email-gerlando.falauto@keymile.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ogabbay@advaoptical.com, bigeasy@linutronix.de,
	"David S. Miller" <davem@davemloft.net>,
	Andy Fleming <afleming@freescale.com>,
	Kumar Gala <galak@kernel.crashing.org>
To: Gerlando Falauto <gerlando.falauto@keymile.com>,
	netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444403708-16576-1-git-send-email-gerlando.falauto@keymile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Gerlando Falauto wrote:
>
> Change-Id: If1e7d8931f440ea9259726c36d3df797dda016fb

You need to remove these from patches that are emailed, and fix the 
pointer type comparison.

Otherwise,

Acked-by: Timur Tabi <timur@tabi.org>
