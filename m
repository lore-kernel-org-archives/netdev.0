From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH] bonding: added 802.3ad round-robin hashing policy for
 single TCP session balancing
Date: Fri, 14 Jan 2011 21:41:09 +0100
Message-ID: <4D30B4E5.1090203@gmail.com>
References: <20110114190714.GA11655@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
To: "Oleg V. Ukhno" <olegu@yandex-team.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:64507 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab1ANUlQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jan 2011 15:41:16 -0500
Received: by wwi17 with SMTP id 17so77775wwi.1
        for <netdev@vger.kernel.org>; Fri, 14 Jan 2011 12:41:15 -0800 (PST)
In-Reply-To: <20110114190714.GA11655@yandex-team.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 14/01/2011 20:07, Oleg V. Ukhno a =E9crit :

> +
> +		For correct load baalncing on the receiving side you must
> +		configure switch for using src-dst-mac or src-mac hashing
> +		mode.

Typo in baalncing -> balancing.

	Nicolas.
