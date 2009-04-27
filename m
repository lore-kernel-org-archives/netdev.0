From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] pcnet32: Remove redundant set of skb->dev
Date: Mon, 27 Apr 2009 02:42:28 -0700 (PDT)
Message-ID: <20090427.024228.157971303.davem@davemloft.net>
References: <1240602512.7304.11.camel@Maple>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pcnet32@verizon.net
To: john.dykstra1@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51898
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752297AbZD0Jme (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:42:34 -0400
In-Reply-To: <1240602512.7304.11.camel@Maple>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Dykstra <john.dykstra1@gmail.com>
Date: Fri, 24 Apr 2009 19:48:32 +0000

> Remove redundant set of skb->dev (now handled for ethernet
> drivers by eth_type_trans()).
> 
> Signed-off-by: John Dykstra <john.dykstra1@gmail.com>

Applied, thanks John.
