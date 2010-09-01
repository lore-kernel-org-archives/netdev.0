From: David Miller <davem@davemloft.net>
Subject: Re: [net-next] ipv6: Export in6addr_any for use by modules.
Date: Wed, 01 Sep 2010 11:07:10 -0700 (PDT)
Message-ID: <20100901.110710.67895761.davem@davemloft.net>
References: <1283274495-12416-1-git-send-email-greearb@candelatech.com>
	<4C7D89CF.3040307@candelatech.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56266
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751204Ab0IASGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 14:06:53 -0400
In-Reply-To: <4C7D89CF.3040307@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>
Date: Tue, 31 Aug 2010 16:01:35 -0700

> On 08/31/2010 10:08 AM, Ben Greear wrote:
>> Some upcoming cifs code, could make use of this, at least.
> 
> Actually, it's probably not worth the dependency on ipv6
> for this small bit of code savings, so at least for cifs,
> this probably isn't useful.

Completely agreed.
