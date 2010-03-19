From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 1/3] jme: Fix VLAN memory leak
Date: Thu, 18 Mar 2010 21:14:16 -0700 (PDT)
Message-ID: <20100318.211416.70191352.davem@davemloft.net>
References: <1268820571-2092-1-git-send-email-cooldavid@cooldavid.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ethanhsiao@jmicron.com,
	devinchiu@jmicron.com, hcchao@jmicron.com, stable@kernel.org
To: cooldavid@cooldavid.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750695Ab0CSENz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Mar 2010 00:13:55 -0400
In-Reply-To: <1268820571-2092-1-git-send-email-cooldavid@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: cooldavid@cooldavid.org
Date: Wed, 17 Mar 2010 18:09:29 +0800

> From: Guo-Fu Tseng <cooldavid@cooldavid.org>
> 
> Fix memory leak while receiving 8021q tagged packet which is not
> registered by user.
> 
> Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

Applied.
