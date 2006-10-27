From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Fri, 27 Oct 2006 11:10:12 +0200
Message-ID: <4541CCF4.4050306@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com> <45408397.8070404@fr.ibm.com> <20061026085659.33b4c6dd@freekitty> <200610271134.56830.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:65414 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1946256AbWJ0JKN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Oct 2006 05:10:13 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k9R9AB2j271374
	for <netdev@vger.kernel.org>; Fri, 27 Oct 2006 09:10:11 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9R9Cltp413916
	for <netdev@vger.kernel.org>; Fri, 27 Oct 2006 10:12:47 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9R9AA4j014193
	for <netdev@vger.kernel.org>; Fri, 27 Oct 2006 10:10:11 +0100
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200610271134.56830.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


[ ... ]

Dmitry Mishin wrote:
> Stephen, 
> 
> Virtualized container can be secure, if it is complete system virtualization, 
> not just an application container. OpenVZ implements such and it is used hard 
> over the world. And of course, we care a lot to keep hostile root from
> killing whole system.

OpenVZ power !!

> OpenVZ uses virtualization on IP level (implemented by Andrey Savochkin, 
> http://marc.theaimsgroup.com/?l=linux-netdev&m=115572448503723), with all
> necessary network objects isolated/virtualized, such as sockets, devices, 
> routes, netfilters, etc.

No, it uses virtualization at layer 2 and I had already mention it 
before (see the first email of the thread), but thank you for the email 
thread pointer.

The discussion is not to convince Stephen that layer 2 or layer 3 is the 
best but to present the pros and the cons of each solution and to have a 
point of view from a network gourou guy.

Regards.

	-- Daniel




