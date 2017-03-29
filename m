From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] bnxt_en: Small misc. fixes.
Date: Wed, 29 Mar 2017 14:07:35 -0700 (PDT)
Message-ID: <20170329.140735.855835984747182120.davem@davemloft.net>
References: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: michael.chan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51370 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932727AbdC2VHj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 17:07:39 -0400
In-Reply-To: <1490744851-19985-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>
Date: Tue, 28 Mar 2017 19:47:28 -0400

> Fix a NULL pointer crash in open failure path, wrong arguments when
> printing error messages, and a DMA unmap bug in XDP shutdown path.

Series applied.
