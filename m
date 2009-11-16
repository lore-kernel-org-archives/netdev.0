From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] act_mirred: cleanup
Date: Mon, 16 Nov 2009 02:48:24 -0800 (PST)
Message-ID: <20091116.024824.267061616.davem@davemloft.net>
References: <412e6f7f0911160033h649b44b2o669196b8b14bf6fc@mail.gmail.com>
	<1258363479.3251.25.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52876
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751445AbZKPKsJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:48:09 -0500
In-Reply-To: <1258363479.3251.25.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Mon, 16 Nov 2009 04:24:39 -0500

> On Mon, 2009-11-16 at 16:33 +0800, Changli Gao wrote:
>> act_mirred: cleanup
>> 
>> 1. don't let go back using goto.
>> 2. don't call skb_act_clone() until it is necessary.
>> 3. one exit of the critical context.
>> 
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
> 
> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>

Applied.
