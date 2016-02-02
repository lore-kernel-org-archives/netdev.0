From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: Re: [RESEND,01/10] net: wireless: ath: Remove unnecessary semicolon
Date: Tue, 2 Feb 2016 22:12:12 +0530
Message-ID: <20160202164212.GD8235@sudip-laptop>
References: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvalo@qca.qualcomm.com, ath10k@lists.infradead.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: punit vara <punitvara@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1445972565-14963-1-git-send-email-punitvara@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 28, 2015 at 12:32:36AM +0530, punit vara wrote:
> This patch is to the htt_rx.c that removes unneeded semicolon which is
> reported by coccicheck.
> 
> Here semicolon just create empty statement so please remote it.

s/remote/remove

Instead of "net: wireless: ath: Remove unnecessary semicolon" the subject
should be "ath10k: Remove unnecessary semicolon"

and please combine this patch and the next patch as they are similar
change to the same driver.

regards
sudip
