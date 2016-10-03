From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/3] openvswitch: mpls fix and clean up
Date: Mon, 03 Oct 2016 02:00:46 -0400 (EDT)
Message-ID: <20161003.020046.660485171656820331.davem@davemloft.net>
References: <cover.1475255100.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dsa@cumulusnetworks.com, pshelar@ovn.org
To: jbenc@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38742 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbcJCGAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2016 02:00:49 -0400
In-Reply-To: <cover.1475255100.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Benc <jbenc@redhat.com>
Date: Fri, 30 Sep 2016 19:08:04 +0200

> Convert to the new mpls skb layout the last remaining place in openvswitch,
> forgotten on the mpls GSO rework. The GSO rework also allows for some
> cleanup in the third patch.

Series applied, thanks.
