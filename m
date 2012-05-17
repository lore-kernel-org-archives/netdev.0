From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH 2/5] drivers/net: delete all code/drivers depending on
 CONFIG_MCA
Date: Thu, 17 May 2012 12:51:37 -0400
Message-ID: <4FB52C99.6010303@windriver.com>
References: <1337272841-25931-1-git-send-email-paul.gortmaker@windriver.com> <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, <JBottomley@parallels.com>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:60939 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758969Ab2EQQvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 12:51:41 -0400
In-Reply-To: <1337272841-25931-3-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12-05-17 12:40 PM, Paul Gortmaker wrote:

[..]

>  18 files changed, 18 insertions(+), 5288 deletions(-)
>  delete mode 100644 drivers/net/ethernet/8390/ne2.c
>  delete mode 100644 drivers/net/ethernet/8390/smc-mca.c
>  delete mode 100644 drivers/net/ethernet/i825xx/3c523.c
>  delete mode 100644 drivers/net/ethernet/i825xx/3c523.h
>  delete mode 100644 drivers/net/ethernet/i825xx/3c527.c

I can also obviously delete 3c527.h too.  Not sure why I didn't
notice that until just now...  :(

Paul.
---
