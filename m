From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] enic: enic_ethtool: fix sparse warning
Date: Thu, 05 Feb 2015 16:05:35 -0800 (PST)
Message-ID: <20150205.160535.1151433430366493570.davem@davemloft.net>
References: <1423150195-14742-1-git-send-email-prabhakar.csengg@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: benve@cisco.com, ssujith@cisco.com, _govind@gmx.com,
	neepatel@cisco.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: prabhakar.csengg@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423150195-14742-1-git-send-email-prabhakar.csengg@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lad Prabhakar <prabhakar.csengg@gmail.com>
Date: Thu,  5 Feb 2015 15:29:55 +0000

> From: "Lad, Prabhakar" <prabhakar.csengg@gmail.com>
> 
> this patch fixes following sparse warning:
> 
> enic_ethtool.c:95:6: warning: symbol 'enic_intr_coal_set_rx' was not declared. Should it be static?
> 
> Signed-off-by: Lad, Prabhakar <prabhakar.csengg@gmail.com>

Applied.
