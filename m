From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] gianfar v3: implement nfc
Date: Thu, 16 Jun 2011 23:31:02 -0400 (EDT)
Message-ID: <20110616.233102.1659546586182470974.davem@davemloft.net>
References: <1308064750.13416.15.camel@DENEC1DT0191>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	sebastian.poehn@belden.com
To: sebastian.belden@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48984 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755028Ab1FQDbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2011 23:31:09 -0400
In-Reply-To: <1308064750.13416.15.camel@DENEC1DT0191>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Sebastian P=F6hn" <sebastian.belden@googlemail.com>
Date: Tue, 14 Jun 2011 17:19:10 +0200

> +	list_for_each_entry(comp, &priv->rx_list.list, list)
> +	{

Please put the openning brace at the end of the previous line.

You did this in several locations of the patch.
