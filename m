From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix checksum annotation in udp6_csum_init
Date: Sat, 11 Jun 2016 21:10:23 +0200
Message-ID: <1465672223.2104796.634815601.681FF996@webmail.messagingengine.com>
References: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:38428 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751823AbcFKTKY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2016 15:10:24 -0400
In-Reply-To: <1465671401-6329-1-git-send-email-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2016, at 20:56, Hannes Frederic Sowa wrote:
> Cc: Tom Herbert <tom@herbertland.com>
> Fixes: 4068579e1e098fa ("net: Implmement RFC 6936 (zero RX csums for
> UDP/IPv6")
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Sorry for the noise, I will send a better patch in a minute.
