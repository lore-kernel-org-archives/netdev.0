From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] bnxt_en: 2 bug fixes.
Date: Wed, 04 May 2016 17:12:07 -0400 (EDT)
Message-ID: <20160504.171207.54117266511466251.davem@davemloft.net>
References: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43546 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751545AbcEDVMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 17:12:09 -0400
In-Reply-To: <1462395404-21875-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Wed,  4 May 2016 16:56:42 -0400

> Fix crash on ppc64 due to missing memory barrier and restore multicast
> after reset.

Looks good, series applied, thanks.
