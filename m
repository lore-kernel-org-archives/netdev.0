From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/6] bnxt_en: Add support for NS2 Nitro.
Date: Tue, 19 Jul 2016 16:29:54 -0700 (PDT)
Message-ID: <20160719.162954.9403711042376306.davem@davemloft.net>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40414 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751827AbcGSX34 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 19:29:56 -0400
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Mon, 18 Jul 2016 07:15:19 -0400

> This series adds support for the embedded version of the
> ethernet controller (Nitro) in the North Star 2 SoC.  There are a number
> of features not supported and a software workaround for a hardware rx
> bug is required for Nitro A0.  Please review.

Series applied, thanks.
