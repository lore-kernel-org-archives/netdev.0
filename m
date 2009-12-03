From: David Miller <davem@davemloft.net>
Subject: Re: [tproxy,regression] tproxy broken in 2.6.32
Date: Wed, 02 Dec 2009 22:31:17 -0800 (PST)
Message-ID: <20091202.223117.228943068.davem@davemloft.net>
References: <1259585129.3992.13.camel@nienna.balabit>
	<1259589577.873.30.camel@bigi>
	<1259674488.3168.45.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hidden@balabit.hu, hidden@sch.bme.hu, kaber@trash.net,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751167AbZLCGbL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 01:31:11 -0500
In-Reply-To: <1259674488.3168.45.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Tue, 01 Dec 2009 08:34:48 -0500

> On Mon, 2009-11-30 at 08:59 -0500, jamal wrote:
> 
>> [I could move the check into fib_validate, but that would punish other
>> users with a few extra cycles]. 
> 
> As in the following patch (gleaned from Patrick's patch on send to self)

Tproxy folks, please have a look at Jamal's patch, thanks.
