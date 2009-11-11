From: Naveen BN <naveen.bn@globaledgesoft.com>
Subject: Re: xfrm command fails
Date: Wed, 11 Nov 2009 11:37:21 +0530
Message-ID: <4AFA5499.2090605@globaledgesoft.com>
References: <4AFA4B60.3090306@globaledgesoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gesmail.globaledgesoft.com ([203.76.137.4]:37046 "EHLO
	gesmail.globaledgesoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751829AbZKKG12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:27:28 -0500
Received: from naveen.globaledgesoft.com (unknown [172.16.8.36])
	by gesmail.globaledgesoft.com (Postfix) with ESMTP id ED6A617B437
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2009 11:57:32 +0530 (IST)
In-Reply-To: <4AFA4B60.3090306@globaledgesoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am using fedora with version => 2.6.23.1-42.fc8.
Please guide me to solve the error message "RTNETLINK answers: Function 
not implemented"

Regards
Naveen
Naveen BN wrote:
> Hi All
> I am trying to create a security association using ip xfrm command, 
> but i get an message saying
> "*RTNETLINK answers: Function not implemented*" and ip xfrm state 
> succeeds in displaying  sa  written using setkey .
>
> ip xfrm state add src 192.168.1.20 dst 192.168.1.5 proto esp spi 
> 0x354cb04b mode tunnel reqid 16385 replay-window 32 auth hmac 
> 0xecf02a5cf6568556e1bdcd961c7ec3f92afd01cc enc cbc 
> 0x5c0cfa9672ce67ba545b593076dfb278 sel src 0.0.0.0/0 dst 0.0.0.0/0
>
> ERROR message => "RTNETLINK answers: Function not implemented"
>
> Regards
> Naveen
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

