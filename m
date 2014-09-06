From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: remove DSP_NEVER_DEFINED and adjust code
 identation
Date: Fri, 05 Sep 2014 22:20:50 -0700 (PDT)
Message-ID: <20140905.222050.386458461943550928.davem@davemloft.net>
References: <1409923571-28627-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1409923571-28627-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  5 Sep 2014 14:26:11 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The DSP_NEVER_DEFINED #ifdef is confusing, it slips in an
> extra } which is not required because the previous code is
> indented incorrectly.  Correct the identation and remove the
> extraneous DSP_NEVER_DEFINED
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next, thanks.
