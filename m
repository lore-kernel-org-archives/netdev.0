From: Simba <simba@lionking.at>
Subject: Ethernet Frame Generation
Date: Tue, 27 Mar 2007 17:27:42 +0200
Message-ID: <460937EE.8050703@lionking.at>
References: <20070327.224537.09436398.yoshfuji@linux-ipv6.org> <20070327142519.GN521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from greylion.org ([213.208.138.14]:35205 "EHLO www.greylion.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753901AbXC0Pcf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2007 11:32:35 -0400
Received: from [10.99.77.1] (kovu.samariterbund.net [83.65.199.82] (may be forged))
	(authenticated bits=0)
	by www.greylion.org (8.13.1/8.13.1) with ESMTP id l2RFO5i0024288
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 27 Mar 2007 17:24:06 +0200
In-Reply-To: <20070327142519.GN521@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings,

I am new to this list. I have a very special question.

I am currently working on a new l2/l3 protocol (just for
research reasons) and i would like to make a test implementation
in the linux kernel.

For this i need to modify the ethernet header and replace it
with my header. The payload of this header holds the raw data, or
an TCP segment, or an UDP datagram.

The problem is, that i try to find out, where this code is located
in the kernel source.

I found out, that most of the ethernet handling can be found in eth.c
I am just not sure, if there are other dependencies which i need to
have a look at. I tried to find more information on the internet but
couldnt actually.

So if you can help me with this question i would really really 
appreciate it.
I am quite new to this, and i am sorry, if it sounds like a silly 
question for some of you.

The implementation should at the moment only go that far, that i can
make two patched linux boxes to talk to each other.

Thanks for your help

Greetings
Christoph Kellner

