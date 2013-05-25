From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] tg3: Misc cleanups and refactoring
Date: Fri, 24 May 2013 22:23:49 -0700 (PDT)
Message-ID: <20130524.222349.1846242697618713539.davem@davemloft.net>
References: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nsujir@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58527 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954Ab3EYFXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 May 2013 01:23:52 -0400
In-Reply-To: <1369343487-6453-1-git-send-email-nsujir@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Date: Thu, 23 May 2013 14:11:21 -0700

> Nithin Nayak Sujir (6):
>   tg3: Split APE driver state change out of boot reset signature update
>   tg3: Simplify ring control block setup
>   tg3: Make tg3_rings_reset() more concise
>   tg3: Use descriptive label names in tg3_start
>   tg3: Fix misplaced empty line
>   tg3: Remove unnecessary lock around tg3_flag_set

Series applied, thanks.
