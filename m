From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 1/2][XFRM]: Sub-policies beautification
Date: Fri, 17 Nov 2006 11:49:54 -0500
Message-ID: <1163782194.5219.3.camel@jzny2>
References: <1163772616.5107.40.camel@jzny2>
	 <20061117164253.GE8693@postel.suug.ch>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Masahide NAKAMURA <nakam@linux-ipv6.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx03.cybersurf.com ([209.197.145.106]:14990 "EHLO
	mx03.cybersurf.com") by vger.kernel.org with ESMTP id S1755705AbWKQQt4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Nov 2006 11:49:56 -0500
Received: from mail.cyberus.ca ([209.197.145.21])
	by mx03.cybersurf.com with esmtp (Exim 4.30)
	id 1Gl6ue-0002lj-8w
	for netdev@vger.kernel.org; Fri, 17 Nov 2006 11:50:00 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061117164253.GE8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-17-11 at 17:42 +0100, Thomas Graf wrote:

> 
> Could you maybe use u8 instead of the  userspace alternative __u8?
> 

Good catch. I think i know how i missed that one - TheLinuxWay;->
theres a few __u8s in there unrelated. So i will send an additional
patch that fixes that and the rest of em. Sounds good?

cheers,
jamal



