From: Alex Sidorenko <alexandre.sidorenko@hp.com>
Subject: Re: An inconsistency/bug in ingress netem timestamps
Date: Fri, 17 Apr 2009 12:50:02 -0400
Message-ID: <200904171250.02258.alexandre.sidorenko@hp.com>
References: <20090416.031034.41207844.davem@davemloft.net> <20090416214846.GA9375@ami.dom.local> <20090417.050422.134655407.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "jarkao2@gmail.com" <jarkao2@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:4406 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756038AbZDQQuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 12:50:03 -0400
In-Reply-To: <20090417.050422.134655407.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On April 17, 2009 08:04:22 am David Miller wrote:
> Meanwhile, Alexandre can you test Jarek's patch for your case?

I have applied Jarek's patch to 2.6.29.1 and tested with 'ping'. Everything 
works fine.

Alex
