From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bonding: add 802.3ad support for 25G speeds
Date: Thu, 16 Mar 2017 20:27:36 -0700 (PDT)
Message-ID: <20170316.202736.777214021470373753.davem@davemloft.net>
References: <20170314154832.13719-1-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, j.vosburgh@gmail.com,
        vfalico@gmail.com, andy@greyhouse.net, netdev@vger.kernel.org
To: jarod@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:53780 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdCQD2L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 23:28:11 -0400
In-Reply-To: <20170314154832.13719-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarod Wilson <jarod@redhat.com>
Date: Tue, 14 Mar 2017 11:48:32 -0400

> Cut-n-paste enablement of 802.3ad bonding on 25G NICs, which currently
> report 0 as their bandwidth.
> 
> CC: Jay Vosburgh <j.vosburgh@gmail.com>
> CC: Veaceslav Falico <vfalico@gmail.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Applied.
