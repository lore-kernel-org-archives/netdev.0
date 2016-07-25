From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] kcm: remove redundant -ve error check and return path
Date: Mon, 25 Jul 2016 11:17:41 -0700 (PDT)
Message-ID: <20160725.111741.799135461651530599.davem@davemloft.net>
References: <1469210652-4622-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, jslaby@suse.cz, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469210652-4622-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 22 Jul 2016 19:04:12 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The check for a -ve error is redundant, remove it and just
> immediately return the return value from the call to
> seq_open_net.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
