From: Alexey Toptygin <alexeyt@freeshell.org>
Subject: Re: [PATCH 0/5] net socket family patches
Date: Thu, 10 Aug 2006 05:36:13 +0000 (UTC)
Message-ID: <Pine.NEB.4.64.0608100532010.9039@ukato.freeshell.org>
References: <20060809183138.332023530@localhost.localdomain>
 <20060809.170641.02297593.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.freeshell.ORG ([192.94.73.18]:18667 "EHLO sdf.lonestar.org")
	by vger.kernel.org with ESMTP id S1161037AbWHJFg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2006 01:36:27 -0400
Received: from sdf.lonestar.org (IDENT:alexeyt@ukato.freeshell.org [192.94.73.7])
	by sdf.lonestar.org (8.13.5.20060308/8.12.10) with ESMTP id k7A5aEll014834
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 05:36:14 GMT
Received: from localhost (alexeyt@localhost)
	by sdf.lonestar.org (8.13.5.20060308/8.12.8/Submit) with ESMTP id k7A5aDwm029848
	for <netdev@vger.kernel.org>; Thu, 10 Aug 2006 05:36:13 GMT
To: netdev@vger.kernel.org
In-Reply-To: <20060809.170641.02297593.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 9 Aug 2006, David Miller wrote:

> From: Stephen Hemminger <shemminger@osdl.org>
> Date: Wed, 09 Aug 2006 11:31:38 -0700
>
>> These patches cleanup the net socket family interface and
>> convert it to RCU. This is new stuff that should go into 2.6.19
>> (if it is ready). Andrew could you put it in -mm as well?
>
> Andrew pulls net-2.6.19 so there is no need to ask him to
> put networking patches explicitly into -mm

I've been wondering - are the relationships of which of the various kernel 
trees pull patches from which other ones documented anywhere? If so, I'd 
love to read about it.

 			Alexey
