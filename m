From: David Miller <davem@davemloft.net>
Subject: Re: dhclient, checksum and tap
Date: Sun, 27 Jun 2010 21:59:18 -0700 (PDT)
Message-ID: <20100627.215918.71117258.davem@davemloft.net>
References: <20100626211419.GA3646@redhat.com>
	<20100626.200320.43025947.davem@davemloft.net>
	<20100627082439.GA8472@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert.xu@redhat.com, netdev@vger.kernel.org
To: mst@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40508
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753627Ab0F1E7I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jun 2010 00:59:08 -0400
In-Reply-To: <20100627082439.GA8472@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael S. Tsirkin" <mst@redhat.com>
Date: Sun, 27 Jun 2010 11:24:40 +0300

> Just to spell it out for me, you think the hack should be done
> in vhost-net?

Pretty much, yes.
