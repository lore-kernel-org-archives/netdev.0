From: Santwona.Behera@Sun.COM
Subject: Re: [gkernel-commit] [PATCH 1/3] [ethtool] Add support for RX packet
 classification in a network device
Date: Mon, 09 Feb 2009 19:05:26 -0800
Message-ID: <4990EEF6.80602@Sun.COM>
References: <4990B855.30905@Sun.COM> <4990C5C3.7080800@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	davem@davemloft.net, Matheos Worku <Matheos.Worku@Sun.COM>,
	Mehdi Bonyadi <Mehdi.Bonyadi@Sun.COM>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:37177 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751357AbZBJDF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Feb 2009 22:05:29 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1A35Scn027794
	for <netdev@vger.kernel.org>; Mon, 9 Feb 2009 19:05:28 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KET00100XR8A900@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Mon,
 09 Feb 2009 19:05:28 -0800 (PST)
In-reply-to: <4990C5C3.7080800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/ 9/09 04:09 PM, Jeff Garzik wrote:
> Once the ethtool interface change is accepted in the upstream kernel, I 
> will be happy to add ethtool(8) support.
> 
> I would say, though, adding 1000 lines of code, you might as well put 
> that into a new file rxclass.c, to keep all that together in a nice tidy 
> unit.

I agree. I will redo the ethtool(8) patch as recommended.

thanks,
--santwona

> 
>     Jeff
> 
> 
> 
> 
