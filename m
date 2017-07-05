From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/11] sctp: remove typedefs from structures
 part 2
Date: Wed, 05 Jul 2017 09:06:58 +0100 (WEST)
Message-ID: <20170705.090658.1783363888745270081.davem@davemloft.net>
References: <cover.1499214692.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36620 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752525AbdGEIHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 04:07:09 -0400
In-Reply-To: <cover.1499214692.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Wed,  5 Jul 2017 08:32:18 +0800

> As we know, typedef is suggested not to use in kernel, even checkpatch.pl
> also gives warnings about it. Now sctp is using it for many structures.
> 
> All this kind of typedef's using should be removed. This patchset is the
> part 2 to remove it for another 11 basic structures.
> 
> Just as the part 1, No any code's logic would be changed in these patches,
> only cleaning up.

net-next is closed, please resubmit this when the tree opens back
up.
