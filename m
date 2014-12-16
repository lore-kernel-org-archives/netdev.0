From: Erik Arfvidson <earfvids@redhat.com>
Subject: Re: Adding Unisys virtnic.c to the Network Tree
Date: Tue, 16 Dec 2014 15:52:01 -0500
Message-ID: <54909B71.10609@redhat.com>
References: <5490976C.20409@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benjamin.romer@unisys.com, dzickus@redhat.com, prarit@redhat.com,
	Bruce.Vessey@unisys.com, sparmaintainer@unisys.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40884 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751091AbaLPUuy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Dec 2014 15:50:54 -0500
In-Reply-To: <5490976C.20409@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I'm a partner engineer at Red Hat working for Unisys. Currently most of 
our driver for our system reside in the staging tree Maintained by Greg 
KH. It was suggested by one of the engineers at Red Hat Don Zickus that 
in order to accelerate the process of moving the remaining drivers we 
pushed directly to their specific system in the Linux Kernel. Currently 
virtnic which is our Virtual Network driver resides internally at Unisys 
and dependencies are in the staging tree(drivers/staging/unisys/). So 
would you be willing to take a look at our Network driver in order to 
add it to your Network tree?

Cheers,
Erik Arfvidson
