From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [patch 1/1] qeth: use ndo_set_features callback for initial setup
 and recovery
Date: Wed, 18 May 2011 15:43:11 +0200
Message-ID: <BANLkTik3A8zdDODnSntYZs8sfBvdtLGrOw@mail.gmail.com>
References: <20110518132834.728225299@de.ibm.com> <20110518132905.064355130@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
To: frank.blaschka@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:52672 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932801Ab1ERNnc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:43:32 -0400
In-Reply-To: <20110518132905.064355130@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/18  <frank.blaschka@de.ibm.com>:
> From: Frank Blaschka <frank.blaschka@de.ibm.com>
>
> This patch uses the ndo_set_features callback during normal device
> startup or recovery to turn on hardware RX checksum. Patch was done
> with much help from Michal Miroslaw, thx!!!
>
> Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>

[regarding usage of ndo_set_features and friends]
Reviewed-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
