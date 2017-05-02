From: David Miller <davem@davemloft.net>
Subject: those bpf binutils testsuite failures..
Date: Mon, 01 May 2017 22:45:42 -0400 (EDT)
Message-ID: <20170501.224542.1972350718369704991.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aconole@bytheb.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41158 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750817AbdEBCpn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 22:45:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I wonder if whatever tool you used to get rid of trailing whitespace
did so in the testsuite foo.d files too?  That definitely is
undesirable :-)
