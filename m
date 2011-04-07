From: <Ajit.Khaparde@Emulex.Com>
Subject: RE: [PATCH] net: benet: convert to hw_features
Date: Thu, 7 Apr 2011 14:35:52 -0700
Message-ID: <c8b7f620-d2da-482e-9601-b828d61cc9ec@exht1.ad.emulex.com>
References: <20110407124348.A8F1E13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <Sathya.Perla@Emulex.Com>, <subbu.seetharaman@emulex.com>
To: <mirq-linux@rere.qmqm.pl>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9431 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753158Ab1DGVjj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 17:39:39 -0400
In-Reply-To: <20110407124348.A8F1E13909@rere.qmqm.pl>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

________________________________________
=46rom: Micha=B3 Miros=B3aw [mirq-linux@rere.qmqm.pl]
Sent: Thursday, April 07, 2011 7:43 AM
To: netdev@vger.kernel.org
Cc: Perla, Sathya; Seetharaman, Subramanian; Khaparde, Ajit
Subject: [PATCH] net: benet: convert to hw_features

> Simple conversion.

> This also fixes a bug in TX checksum toggling --- driver was changing
> NETIF_F_HW_CSUM instead of NETIF_F_IP_CSUM+NETIF_F_IPV6_CSUM.

> Signed-off-by: Micha=B3 Miros=B3aw mirq-linux@rere.qmqm.pl

Acked-by: Ajit Khaparde <ajit.khaparde@emulex.com>

Thanks