From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fddi: print an address with %p format specifier rather
 than %x
Date: Sun, 07 Jun 2015 00:32:32 -0700 (PDT)
Message-ID: <20150607.003232.1338073717948581199.davem@davemloft.net>
References: <1433528351-31778-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1433528351-31778-1-git-send-email-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri,  5 Jun 2015 19:19:11 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The debug is printing the struct smt_header * address using
> the %x format specifier. Fix it to use %p instead.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
