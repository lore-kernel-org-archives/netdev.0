From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 2/3] net: TCP thin linear timeouts
Date: Thu, 29 Oct 2009 10:01:57 -0700
Message-ID: <4AE9CA85.9080409@hp.com>
References: <4AE72079.4030504@simula.no> <4AE7262B.1060703@gmail.com>	<4AE83FE4.1050309@nets.rwth-aachen.de>	<alpine.DEB.2.00.0910281618330.19761@wel-95.cs.helsinki.fi> <58396856-6D7E-4CE1-8D66-D1F11205B0D5@simula.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Arnd Hannemann <hannemann@nets.rwth-aachen.de>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, shemminger@vyatta.com,
	David Miller <davem@davemloft.net>
To: Andreas Petlund <apetlund@simula.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:42170 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756011AbZJ2RB4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 13:01:56 -0400
In-Reply-To: <58396856-6D7E-4CE1-8D66-D1F11205B0D5@simula.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just how thin can a thin stream be when a thin stream is found thin? (to the 
cadence of "How much wood could a woodchuck chuck if a woodchuck could chuck wood?")

Does a stream get so thin that a user's send could not be split into four, 
sub-MSS TCP segments?

rick jones
