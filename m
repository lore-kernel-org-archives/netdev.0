From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next] ipv6: almost identical frag hashing funcs combined
Date: Wed, 01 Oct 2008 10:18:08 -0400
Message-ID: <48E386A0.5070107@hp.com>
References: <Pine.LNX.4.64.0810010146001.27688@wrl-59.cs.helsinki.fi> <20081001011838.GB970@ghostprotocols.net> <20081001.025426.33354887.davem@davemloft.net> <Pine.LNX.4.64.0810011309480.1034@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>,
	Netdev <netdev@vger.kernel.org>, Patrick Hardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:21396 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087AbYJAOSN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2008 10:18:13 -0400
In-Reply-To: <Pine.LNX.4.64.0810011309480.1034@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> Btw, does somebody know a tool which can "diff" --side-by-side like a=
ny=20
> number of inputs? I'd be interested...

vimdiff/gvimdiff

-Brian
