From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: restore ip source validation WAS(Re:
 [tproxy,regression] tproxy broken in 2.6.32
Date: Sun, 13 Dec 2009 19:10:24 -0800 (PST)
Message-ID: <20091213.191024.193699730.davem@davemloft.net>
References: <1260729530.6167.22.camel@bigi>
	<1260731510.6167.25.camel@bigi>
	<1260731716.6167.27.camel@bigi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, hidden@balabit.hu, kaber@trash.net, hidden@sch.bme.hu,
	aschultz@warp10.net, tproxy@lists.balabit.hu,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37760
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932125AbZLNDKX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 22:10:23 -0500
In-Reply-To: <1260731716.6167.27.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: jamal <hadi@cyberus.ca>
Date: Sun, 13 Dec 2009 14:15:16 -0500

> On Sun, 2009-12-13 at 14:11 -0500, jamal wrote:
>> On Sun, 2009-12-13 at 13:38 -0500, jamal wrote:
>> 
>> > Of course. I will resend ..
>> 
>> Updated. Much thanks Julian.
> 
> Grrr. As a self-proclaimed master craftsman man i insist on blaming some
> tool. It must be git! Proper patch attached.

Don't use binary attachments like that please.

It doesn't end up in patchwork properly, and I need that to
happen in order to track people's work effectively.
