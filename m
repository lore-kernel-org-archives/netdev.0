From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ibmvnic: Report errors when failing to
 release sub-crqs
Date: Mon, 17 Apr 2017 13:49:12 -0400 (EDT)
Message-ID: <20170417.134912.1237494749289498748.davem@davemloft.net>
References: <20170414164517.50438.14612.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tlfalcon@linux.vnet.ibm.com,
        jallen@linux.vnet.ibm.com
To: nfont@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56072 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754517AbdDQRtN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 13:49:13 -0400
In-Reply-To: <20170414164517.50438.14612.stgit@ltcalpine2-lp23.aus.stglabs.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please do not submit a set of changes to the same driver like this.

Instead, submit a proper patch series which is numbered (so that the
dependencies betweeen changes, if any, are explciit) and also with
a proper "[PATCH 0/N] ..." header posting which describes what the
patch series is doing, how it is doing it, and why it is doing it
that way.

Thanks.
