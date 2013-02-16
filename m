From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: Universal tap device
Date: Sat, 16 Feb 2013 17:46:25 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1302161743180.8831@nerf07.vanv.qr>
References: <20130216140132.GB1536@minipsycho.orion>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, arnd@arndb.de, ebiederm@xmission.com,
	stephen@networkplumber.org, eric.dumazet@gmail.com,
	davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:54195 "EHLO ares07.inai.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753548Ab3BPQq0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 11:46:26 -0500
In-Reply-To: <20130216140132.GB1536@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 2013-02-16 15:01, Jiri Pirko wrote:

>Hi all.                                                                  
>                                                                         
>Looking at macvtap and thinking about the tap solutions in general,
>I think it would be handly to have some universal tap device.

As in, allowing tuntap to register as an rx_handler for arbitrary
devices?
