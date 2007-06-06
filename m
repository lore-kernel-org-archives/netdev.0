From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Virtual ethernet tunnel
Date: Wed, 06 Jun 2007 12:47:58 -0700 (PDT)
Message-ID: <20070606.124758.85411179.davem@davemloft.net>
References: <4666CEAA.8010903@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, ebiederm@xmission.com, netdev@vger.kernel.org,
	containers@lists.osdl.org, dev@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40514
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751472AbXFFTrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2007 15:47:43 -0400
In-Reply-To: <4666CEAA.8010903@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelianov <xemul@openvz.org>
Date: Wed, 06 Jun 2007 19:11:38 +0400

> Veth stands for Virtual ETHernet. It is a simple tunnel driver
> that works at the link layer and looks like a pair of ethernet
> devices interconnected with each other.

I would suggest choosing a different name.

'veth' is also the name of the virtualized ethernet device
found on IBM machines, driven by driver/net/ibmveth.[ch]

