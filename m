From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 1/2] bpf, s390: fix jit branch offset related to
 ldimm64
Date: Fri, 04 Aug 2017 10:13:28 -0700 (PDT)
Message-ID: <20170804.101328.1848792783426898491.davem@davemloft.net>
References: <20170804154420.6faae20a@TP-holzheu>
        <59847C2F.6010306@iogearbox.net>
        <20170804191033.30bd8f03@TP-holzheu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, ast@fb.com, netdev@vger.kernel.org
To: holzheu@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36294 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752514AbdHDRN3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 13:13:29 -0400
In-Reply-To: <20170804191033.30bd8f03@TP-holzheu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Holzheu <holzheu@linux.vnet.ibm.com>
Date: Fri, 4 Aug 2017 19:10:33 +0200

> At least I would vote for "Cc: stable".

No, please do not ever do this for networking patches.
