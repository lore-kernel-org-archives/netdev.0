From: David Miller <davem@davemloft.net>
Subject: Re: port bound SAs
Date: Tue, 27 Jan 2009 09:21:14 -0800 (PST)
Message-ID: <20090127.092114.153681069.davem@davemloft.net>
References: <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com>
	<497F4071.2040302@trash.net>
	<BB7E16A14DE689469A181EC770AFBF4D02A77522@exch-one.centrify.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: paul.moore@centrify.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42702
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbZA0RVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:21:17 -0500
In-Reply-To: <BB7E16A14DE689469A181EC770AFBF4D02A77522@exch-one.centrify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Paul Moore" <paul.moore@centrify.com>
Date: Tue, 27 Jan 2009 09:13:46 -0800

> the pfkey / xfrm interface throws them away
> 
> i fixed racoon to send the port numbers and they were ignored

Did you actually try "ip xfrm" as Patrick suggested?

Where exactly are the ports "thrown away" for both pfkey and xfrm
cases?
