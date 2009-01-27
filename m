From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: port bound SAs
Date: Tue, 27 Jan 2009 09:21:56 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02A77525@exch-one.centrify.com>
References: <BB7E16A14DE689469A181EC770AFBF4D02A77520@exch-one.centrify.com><497F4071.2040302@trash.net><BB7E16A14DE689469A181EC770AFBF4D02A77522@exch-one.centrify.com> <20090127.092114.153681069.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:46991 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755147AbZA0RWA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 12:22:00 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090127.092114.153681069.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I dont know what ip xfrm means - excuse my ignorance please
I will try it 

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Tuesday, January 27, 2009 9:21 AM
To: Paul Moore
Cc: kaber@trash.net; netdev@vger.kernel.org
Subject: Re: port bound SAs

From: "Paul Moore" <paul.moore@centrify.com>
Date: Tue, 27 Jan 2009 09:13:46 -0800

> the pfkey / xfrm interface throws them away
> 
> i fixed racoon to send the port numbers and they were ignored

Did you actually try "ip xfrm" as Patrick suggested?

Where exactly are the ports "thrown away" for both pfkey and xfrm
cases?
