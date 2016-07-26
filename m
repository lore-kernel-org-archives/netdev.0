From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gtp: #define #define _GTP_H_ and not #define _GTP_H
Date: Mon, 25 Jul 2016 17:55:57 -0700 (PDT)
Message-ID: <20160725.175557.1098722256248519884.davem@davemloft.net>
References: <1469384649-11556-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469384649-11556-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Sun, 24 Jul 2016 19:24:09 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Fix clang build warning:
> 
> ./include/net/gtp.h:1:9: warning: '_GTP_H_' is used as a header
> guard here, followed by #define of a different macro [-Wheader-guard]
> 
> fix by defining _GTP_H_ and not _GTP_H
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
