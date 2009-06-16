From: jamal <hadi@cyberus.ca>
Subject: Re: iproute2 action/policer question
Date: Tue, 16 Jun 2009 08:04:32 -0400
Message-ID: <1245153872.4018.14.camel@dogo.mojatatu.com>
References: <20090615111927.GA12316@ff.dom.local>
	 <1245072728.3948.14.camel@dogo.mojatatu.com>
	 <20090615145222.GA2767@ami.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?Q?Pawe=C5=82?= Staszewski <pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Andreas Henriksson <andreas@fatal.se>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qw-out-2122.google.com ([74.125.92.27]:10500 "EHLO
	qw-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908AbZFPMFw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Jun 2009 08:05:52 -0400
Received: by qw-out-2122.google.com with SMTP id 5so2656682qwd.37
        for <netdev@vger.kernel.org>; Tue, 16 Jun 2009 05:05:54 -0700 (PDT)
In-Reply-To: <20090615145222.GA2767@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2009-06-15 at 16:52 +0200, Jarek Poplawski wrote:

> I've tried debian squeeze (testing) with: iptables v1.4.3.2, iproute2
> -ss090324, and action ipt -j MARK doesn't work. AFAIK debian lenny
> (stable) uses 1.4.2. I've also tried debian rescue probably based on
> lenny (with iptables 1.4.2), and it seemed it didn't work yet (I'll
> re-check this). When you have something new I'd be glad for Cc.

I am suprised it broke again. 
Lets CC the debian iproute maintainer. 

cheers,
jamal

