From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next-2.6] vlan: Use vlan_dev_real_dev in
 vlan_hwaccel_do_receive
Date: Tue, 31 Aug 2010 13:37:44 -0700 (PDT)
Message-ID: <20100831.133744.212393623.davem@davemloft.net>
References: <20100831145817.GB2795@psychotron.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39919
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755482Ab0HaUh2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Aug 2010 16:37:28 -0400
In-Reply-To: <20100831145817.GB2795@psychotron.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 31 Aug 2010 16:58:18 +0200

> [patch net-next-2.6] vlan: Use vlan_dev_real_dev in vlan_hwaccel_do_receive
> 
> Use helper as in other places.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied.
