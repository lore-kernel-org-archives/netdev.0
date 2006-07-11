From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: ipsec tunnel asymmetrical mtu
Date: Tue, 11 Jul 2006 12:32:45 +0200
Message-ID: <BAY103-F97F4BC613EFB6C6BEB70EB2680@phx.gbl>
References: <20060711064232.GA1490@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s38.bay0.hotmail.com ([65.54.246.174]:64550 "EHLO
	bay0-omc2-s38.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1750984AbWGKKct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 06:32:49 -0400
In-Reply-To: <20060711064232.GA1490@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Running this on mimosa 'mitigates' the problem:

ip addr add 172.29.128.1/28 dev eth2

Connections are pretty slow but they aren't
reseted anymore.


