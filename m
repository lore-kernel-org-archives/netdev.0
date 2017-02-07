From: David Miller <davem@davemloft.net>
Subject: kernel data plane
Date: Tue, 07 Feb 2017 12:45:28 -0500 (EST)
Message-ID: <20170207.124528.1236430562373810535.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52868 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbdBGRz4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 12:55:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since I see that you guys have marked the kernel data plane of
openvswitch as experimental and that it "has not been thoroughly
tested" what is your long term plan for deprecation and eventual
removal of it from the tree?

	https://github.com/openvswitch/ovs/commit/602e24ee189b76a72fdd26c9ed70c5f6b919a2f3

If it's experimental and not being tested, I'm not too thrilled about
new feature patches and whatnot being posted which require developer
resources to audit and review if the official message is "don't use
this."

Thank you.
