From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V3 0/9] liquidio CN23XX VF support
Date: Sat, 29 Oct 2016 14:31:26 -0400 (EDT)
Message-ID: <20161029.143126.1818409172503412109.davem@davemloft.net>
References: <1477443430-27170-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: rvatsavayi@caviumnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51018 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932486AbcJ2Sb3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Oct 2016 14:31:29 -0400
In-Reply-To: <1477443430-27170-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Date: Tue, 25 Oct 2016 17:57:01 -0700

> 2) As recommended by you removed custom module parameter max_vfs.

I feel the same way about num_queues_per_{p,v}f.

What's really strange is that there is a reference to num_queues_per_pf
in one of the kernel log messages already.
