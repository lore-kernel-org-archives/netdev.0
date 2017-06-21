From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: mwifiex: debugfs: remove redunant check of mwifiex_dfs_dir
Date: Wed, 21 Jun 2017 15:26:04 +0000 (UTC)
Message-ID: <20170621152604.61B38607CA@smtp.codeaurora.org>
References: <1497517165-145266-1-git-send-email-shawn.lin@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Amitkumar Karwar <amitkarwar@gmail.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Nishant Sarmukadam <nishants@marvell.com>,
        Ganapathi Bhat <gbhat@marvell.com>,
        Xinming Hu <huxm@marvell.com>,
        Shawn Lin <shawn.lin@rock-chips.com>
To: Shawn Lin <shawn.lin@rock-chips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:58273 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751640AbdFUQok (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 12:44:40 -0400
In-Reply-To: <1497517165-145266-1-git-send-email-shawn.lin@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shawn Lin <shawn.lin@rock-chips.com> wrote:

> debugfs_remove already check mwifiex_dfs_dir, so remove it.
> 
> Signed-off-by: Shawn Lin <shawn.lin@rock-chips.com>

Patch applied to wireless-drivers-next.git, thanks.

7c26029f87a3 mwifiex: debugfs: remove redunant check of mwifiex_dfs_dir

-- 
https://patchwork.kernel.org/patch/9788425/

https://wireless.wiki.kernel.org/en/developers/documentation/submittingpatches
