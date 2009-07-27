From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 phonet causes build error
Date: Mon, 27 Jul 2009 08:03:36 -0700 (PDT)
Message-ID: <20090727.080336.246401283.davem@davemloft.net>
References: <200907270927.55728.remi.denis-courmont@nokia.com>
	<4A6D512A.1050504@gmail.com>
	<200907271106.02456.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: remi.denis-courmont@nokia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52387
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751860AbZG0PD3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jul 2009 11:03:29 -0400
In-Reply-To: <200907271106.02456.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "R=E9mi Denis-Courmont" <remi.denis-courmont@nokia.com>
Date: Mon, 27 Jul 2009 11:06:02 +0300

> On Monday 27 July 2009 10:03:06 ext Eric Dumazet wrote:
>>
>> [PATCH] phonet: phonet_device_get() fix
>>
>> net/phonet/pn_dev.c: In function `phonet_device_get':
>> net/phonet/pn_dev.c:99: warning: 'dev' might be used uninitialized i=
n this
>> function
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Acked-by: R=E9mi Denis-Courmont <remi.denis-courmont@nokia.com>

Applied.
