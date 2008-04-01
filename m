From: Andy Fleming <afleming@freescale.com>
Subject: Re: gianfar: multiqueue, vlan pbits -> qos?
Date: Mon, 31 Mar 2008 21:04:26 -0500
Message-ID: <531286A6-5CDB-4D96-9C7A-ECC19898A4D3@freescale.com>
References: <47EE9CCD.8080304@nortel.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Randy Macleod <macleodr@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw01.freescale.net ([192.88.158.102]:42257 "EHLO
	az33egw01.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751282AbYDACEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Mar 2008 22:04:37 -0400
In-Reply-To: <47EE9CCD.8080304@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mar 29, 2008, at 14:47, Randy Macleod wrote:

> Hey Netdevers...
>
>  I'm looking into extending the gianfar driver to
> make use of multiple rx (and maybe tx) queues.
> I've started to read the gianfar source, the Freescale docs and  
> netdev.
>
> Has anyone done this already?
>
> My interest is in LAN network QOS,
> primarily selective discard under overload.
> I'm thinking that I'll create several vlans in my
> network and do a strict vlan priority bit based servicing.
>
> I'm also poking at the multi-queue work that has been
> done and wondering how that might fit into a solution.
> I haven't read the e1000 multiqueue driver yet...
>
> Any tips, flames or code?

Excellent!  I've been wanting to do this for some time, but haven't  
managed to get it to the front of my queue (pun retroactively  
intended).  Feel free to contact me if you have any questions.

Andy
