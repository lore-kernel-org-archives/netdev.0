From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][NET_SCHED] explict hold dev tx lock
Date: Wed, 26 Sep 2007 09:11:51 -0400
Message-ID: <1190812311.4257.6.camel@localhost>
References: <20070919.090937.32177545.davem@davemloft.net>
	 <1190255605.4818.25.camel@localhost> <1190256183.4818.28.camel@localhost>
	 <20070925.192811.08341847.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	kaber@trash.net, dada1@cosmosbay.com, johnpol@2ka.mipt.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.176]:27279 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770AbXIZNMC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2007 09:12:02 -0400
Received: by py-out-1112.google.com with SMTP id u77so4163424pyb
        for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 06:12:01 -0700 (PDT)
In-Reply-To: <20070925.192811.08341847.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-25-09 at 19:28 -0700, David Miller wrote:

> I've applied this to net-2.6.24, although I want to study more deeply
> the implications of this change myself at some point :)

sounds reasonable. Ive done a lot of testing with my 2-3 NIC variants;
ive cced whoever i thought was a stakeholder and they ALL seemed
silently-happy-joyous (wink;->), so letting more people go at it is the
best thing to do. I will be watching that space.

cheers,
jamal

