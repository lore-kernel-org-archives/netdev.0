From: Matheos Worku <Matheos.Worku@Sun.COM>
Subject: Re: [PATCH] [NIU] VLAN does not work with niu driver
Date: Wed, 09 Sep 2009 18:48:12 -0700
Message-ID: <4AA85ADC.5050900@sun.com>
References: <4AA84FE3.6030407@sun.com>
 <20090909.181033.25374239.davem@davemloft.net> <4AA85404.5020300@sun.com>
 <20090909.184410.64382338.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; CHARSET=US-ASCII; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: Joyce.Yu@Sun.COM, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-2.Sun.COM ([192.18.43.133]:36073 "EHLO
	sca-es-mail-2.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751519AbZIJBt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 21:49:27 -0400
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-2.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n8A1nUV3024243
	for <netdev@vger.kernel.org>; Wed, 9 Sep 2009 18:49:30 -0700 (PDT)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7u2-7.04 64bit (built Jul  2 2009))
 id <0KPQ00800FK1VY00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Wed,
 09 Sep 2009 18:49:30 -0700 (PDT)
In-reply-to: <20090909.184410.64382338.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> From: Matheos Worku <Matheos.Worku@Sun.COM>
> Date: Wed, 09 Sep 2009 18:19:00 -0700
> 
>> We can work on a version which implements HW header checking and do
>> pullup accordingly.
> 
> I think using a constant based on the vlan header size would be
> sufficient to fix this.
We will have a patch based on vlan header size.

Regards
Matheos

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
