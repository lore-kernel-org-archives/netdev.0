From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: Generic UDP Encapsulation
Date: Fri, 03 Oct 2014 13:18:15 -0700 (PDT)
Message-ID: <20141003.131815.972110119857439918.davem@davemloft.net>
References: <1412225199-24942-1-git-send-email-therbert@google.com>
	<20141003.131029.1598012589716466958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59193 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750944AbaJCUQJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:16:09 -0400
In-Reply-To: <20141003.131029.1598012589716466958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 03 Oct 2014 13:10:29 -0700 (PDT)

> From: Tom Herbert <therbert@google.com>
> Date: Wed,  1 Oct 2014 21:46:35 -0700
> 
>> Generic UDP Encapsulation (GUE) is UDP encapsulation protocol that
>> encapsulates packets of various IP protocols. The GUE protocol is
>> described in http://tools.ietf.org/html/draft-herbert-gue-01.
> 
> Series applied, thanks Tom.

I had to revert, forgot to 'git add' this file?

net/ipv4/ip_tunnel.c:59:21: fatal error: net/gue.h: No such file or directory
