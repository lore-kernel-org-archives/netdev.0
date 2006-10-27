From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Subject: RE: [PATCH 4 of 9] NetEffect 10Gb RNIC Driver: kernel driver header files
Date: Thu, 26 Oct 2006 19:14:19 -0500
Message-ID: <5E701717F2B2ED4EA60F87C8AA57B7CC064C9EBD@venom2>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <openib-general@openib.org>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.neteffect.com ([204.57.75.68]:53470 "EHLO
	mail2.neteffect.com") by vger.kernel.org with ESMTP
	id S1946048AbWJ0AOV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 20:14:21 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It is part of our connection manager and assists with connection setup
and teardown only.

Glenn.

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net] 
Sent: Thursday, October 26, 2006 7:10 PM
To: Glenn Grundstrom; Glenn Grundstrom
Cc: openib-general@openib.org; netdev@vger.kernel.org
Subject: Re: [PATCH 4 of 9] NetEffect 10Gb RNIC Driver: kernel driver
header files

From: "Glenn Grundstrom" <ggrundstrom@NetEffect.com>
Date: Thu, 26 Oct 2006 19:06:23 -0500

> +#include "nes_tcpip/include/nes_sockets.h"

I want to know what in the world this nes_tcpip thing is?
