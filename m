From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH IPROUTE2] tc-fq_codel: Add manpage
Date: Tue, 05 Jun 2012 05:01:31 +0200
Message-ID: <1338865291.2760.1975.camel@edumazet-glaptop>
References: <1338850557-5199-1-git-send-email-subramanian.vijay@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Dave Taht <dave.taht@gmail.com>
To: Vijay Subramanian <subramanian.vijay@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:37452 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757733Ab2FEDBf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 23:01:35 -0400
Received: by wgbds11 with SMTP id ds11so2932082wgb.1
        for <netdev@vger.kernel.org>; Mon, 04 Jun 2012 20:01:34 -0700 (PDT)
In-Reply-To: <1338850557-5199-1-git-send-email-subramanian.vijay@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-06-04 at 15:55 -0700, Vijay Subramanian wrote:
> This patch adds the manpage for the FQ_CoDel (Fair Queuing Controlled-Delay)
> AQM.
> 
> Signed-off-by: Vijay Subramanian <subramanian.vijay@gmail.com>
> ---
>  man/man8/Makefile      |    2 +-
>  man/man8/tc-fq_codel.8 |  108 ++++++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 109 insertions(+), 1 deletions(-)
>  create mode 100644 man/man8/tc-fq_codel.8

Thanks !

Could you also update man/man8/tc.8 ?
