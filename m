From: Mike_Phillips@URSCorp.com
Subject: Re: Token Ring Hardware Address in ARP
Date: Thu, 25 Apr 2002 12:22:06 -0500
Sender: linux-net-owner@vger.kernel.org
Message-ID: <OFB41AEBD7.9D970803-ON86256BA6.005FEDC4@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: root <jberna@disc.ua.es>
List-Id: netdev.vger.kernel.org

>                I want to know which is the format for token ring 
hardware address to
>set entries in the ARP table. I tried the Ethernet one
>(00:00:00:00:00:00) but doesn't work. Any idea ??

Token ring mac addresses are the same as ethernet, but the high order bits 
have special meaning. You have to ensure the address adheres to these 
requirements.

Mike
Linux Token Ring Project
http://www.linuxtr.net

