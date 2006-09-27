From: Rick Jones <rick.jones2@hp.com>
Subject: Re: mii-tool gigabit support.
Date: Wed, 27 Sep 2006 10:08:14 -0700
Message-ID: <451AAFFE.2020607@hp.com>
References: <20060926145113.7a6791c8@freekitty>	<4519A1D6.1050802@pobox.com>	<20060926150947.3d538547@freekitty> <451A7603.1030204@roinet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jgarzik@pobox.com>, dhinds@pcmcia.sourceforge.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:14728 "EHLO palrel10.hp.com")
	by vger.kernel.org with ESMTP id S1030460AbWI0RIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 13:08:18 -0400
To: David Acker <dacker@roinet.com>
In-Reply-To: <451A7603.1030204@roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> With mii-tool we can do the command below and work with a half duplex 
> hub and a full duplex switch.
> mii-tool -A 10baseT-FD,10baseT-HD eth0

Why, and how often, is that really necessary?

rick jones
