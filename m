From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] Revert "bnx2x: allow nvram test to run when
 device is down"
Date: Tue, 30 Apr 2013 15:49:16 -0400 (EDT)
Message-ID: <20130430.154916.289965268165509683.davem@davemloft.net>
References: <1367314447-10518-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: dmitry@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52684 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932742Ab3D3TtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Apr 2013 15:49:20 -0400
In-Reply-To: <1367314447-10518-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry Kravkov" <dmitry@broadcom.com>
Date: Tue, 30 Apr 2013 12:34:07 +0300

> This reverts commit d2d2d87dfd1a25ee270994c5b9e3eb4690428d32.

Please refer to commits in the following format:

${SHA_ID} ("Commit message header line.")

Thanks.
