From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 10/10] net: remove SK_ROUTE_CAPS from meta ematch
Date: Wed, 13 Jul 2011 20:59:26 -0400
Message-ID: <1310605166.2416.0.camel@mojatatu>
References: <cover.1310601401.git.mirq-linux@rere.qmqm.pl>
	 <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:61261 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204Ab1GNA7a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 20:59:30 -0400
Received: by ywe9 with SMTP id 9so2656146ywe.19
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 17:59:29 -0700 (PDT)
In-Reply-To: <b06d1da00c5f333bb5d8d9f01aa306ff69b99df5.1310601401.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-07-14 at 02:10 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> Remove it, as it indirectly exposes netdev features. It's not used in
> iproute2 (2.6.38) - is anything else using its interface?
>=20

Breaks user ABI.

cheers,
jamal

