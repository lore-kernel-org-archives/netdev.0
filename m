From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v5 0/5] bnx2x: fixes
Date: Tue, 13 Aug 2013 16:04:55 -0700 (PDT)
Message-ID: <20130813.160455.2147057320397972451.davem@davemloft.net>
References: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45245 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754838Ab3HMXE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 19:04:56 -0400
In-Reply-To: <1376349903-3461-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 13 Aug 2013 02:24:58 +0300

> Please consider applying the series of bnx2x fixes to net:
> 	* statistics may cause FW assert
> 	* missing fairness configuration in DCB flow
> 	* memory leak in sriov related part
> 	* Illegal PTE access
> 	* Pagefault crash in shutdown flow with cnic

Series applied, thanks.
