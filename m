From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][RESEND] gtp: #define _UAPI_LINUX_GTP_H_ and not
 _UAPI_LINUX_GTP_H__
Date: Tue, 07 Jun 2016 16:25:58 -0700 (PDT)
Message-ID: <20160607.162558.150936910939335333.davem@davemloft.net>
References: <1465225721-16371-1-git-send-email-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59002 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752387AbcFGX0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 19:26:00 -0400
In-Reply-To: <1465225721-16371-1-git-send-email-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Mon,  6 Jun 2016 16:08:41 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Fix clang build warning:
> 
> ./include/uapi/linux/gtp.h:1:9: warning: '_UAPI_LINUX_GTP_H_' is
> used as a header guard here, followed by #define of a different
> macro [-Wheader-guard]
> 
> fix by defining  _UAPI_LINUX_GTP_H_ and not _UAPI_LINUX_GTP_H__
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thank you.
