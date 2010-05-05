From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pppoe: remove unnecessary checks in
 pppoe_flush_dev
Date: Wed, 05 May 2010 00:56:41 -0700 (PDT)
Message-ID: <20100505.005641.59677780.davem@davemloft.net>
References: <20100504150256.GD2845@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39197
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751903Ab0EEH4e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 03:56:34 -0400
In-Reply-To: <20100504150256.GD2845@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Tue, 4 May 2010 17:02:57 +0200

> pernet memory is guaranteed to exist when notifiers are called.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>

Applied, thank you.
