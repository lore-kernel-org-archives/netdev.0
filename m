From: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 1/1] [PATCH] net: qmi_wwan: fix Gobi device probing for un2430
Date: Tue, 11 Sep 2012 06:59:57 +0200
Message-ID: <22bf77fd-e0de-4a07-acf2-cd816a543ee9@email.android.com>
References: <1347296579-15692-1-git-send-email-pierre.sauter@gmail.com> <20120910.164314.1674016370550788813.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, pierre.sauter@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:49062 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751313Ab2IKFA1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 01:00:27 -0400
In-Reply-To: <20120910.164314.1674016370550788813.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:

>From: pierre.sauter@gmail.com
>Date: Mon, 10 Sep 2012 19:02:59 +0200
>
>> From: Pierre Sauter <pierre.sauter@gmail.com>
>>=20
>> HP un2430 is a Gobi 3000 device. It was mistakenly treated as Gobi
>1000
>> in patch b9f90eb2740203ff2592efe640409ad48335d1c2.
>>=20
>> I own this device and qmi_wwan works again with this fix.
>>=20
>> Signed-off-by: Pierre Sauter <pierre.sauter@gmail.com>
>
>Bjorn, ACK/NACK?

Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>

Thanks for fixing this, Pierre. I wonder how I managed to get this wron=
g. Better look it all over again, I guess...


Bj=C3=B8rn
