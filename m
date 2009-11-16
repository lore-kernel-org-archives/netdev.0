From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 05:24:27 -0500
Message-ID: <1258367067.15912.0.camel@bigi>
References: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
	 <1258365990.3251.33.camel@bigi>
	 <20091116.022144.203823073.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: xiaosuo@gmail.com, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.221.174]:46821 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752251AbZKPKYX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 05:24:23 -0500
Received: by qyk4 with SMTP id 4so2515838qyk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 02:24:29 -0800 (PST)
In-Reply-To: <20091116.022144.203823073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-11-16 at 02:21 -0800, David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Mon, 16 Nov 2009 05:06:30 -0500
 
> > One indent too many? 
> 
> It's actually fixing some stray space characters into a real proper
> tab character.

good enough for me then.

cheers,
jamal

