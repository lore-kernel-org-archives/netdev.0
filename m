From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/14] bnxt_en: updates for net-next.
Date: Thu, 29 Dec 2016 14:42:20 -0500 (EST)
Message-ID: <20161229.144220.119682635828637679.davem@davemloft.net>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56732 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750764AbcL2TmW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 14:42:22 -0500
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Thu, 29 Dec 2016 12:13:30 -0500

> This patch series for net-next contains cleanups, new features and minor
> fixes.  The driver specific busy polling code is removed to use busy
> polling support in core networking.  Hardware RFS support is enhanced with
> added ipv6 flows support and VF support.  A new scheme to allocate TX
> rings from the firmware is implemented for newer chips and firmware.  Plus
> some misc. cleanups, minor fixes, and to add the maintainer entry.  Please
> review.

Looks good, series applied, thanks Michael.
