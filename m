From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH 1/1] ixp4xx_hss: Non-used lut variable
Date: Mon, 24 Nov 2008 17:36:03 +0100
Message-ID: <m3hc5x13po.fsf@maximus.localdomain>
References: <b0438a630811240637i3636b297taafa01f4947a4b1c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?iso-8859-2?Q?Miguel_=C1ngel_=C1lvarez?= <gotzoncabanes@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:39581 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752473AbYKXQgF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 11:36:05 -0500
In-Reply-To: <b0438a630811240637i3636b297taafa01f4947a4b1c@mail.gmail.com>
 ("Miguel =?iso-8859-2?Q?=C1ngel_=C1lvarez=22's?= message of "Mon\, 24 Nov
 2008 15\:37\:42 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"Miguel =C1ngel =C1lvarez" <gotzoncabanes@gmail.com> writes:

> Taking a look to ixp4xx_hss code, I have found a non-used variable in
> hss_config_set_lut. I suppose it is part of a deprecated code. This
> patch removes it.

You must be right. Thanks.
--=20
Krzysztof Halasa
