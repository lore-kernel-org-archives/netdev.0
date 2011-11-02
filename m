From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: RE: bnx2x kerneloops
Date: Wed, 2 Nov 2011 20:19:41 +0200
Message-ID: <1320257981.12759.2.camel@lb-tlvb-dmitry>
References: <SNT113-W64251CF45774789989C835DBD40@phx.gbl> ,
 <1320234845.2688.3.camel@lb-tlvb-dmitry>
 <SNT113-W38A7D5A673342F70A1F808DBD40@phx.gbl>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Carlos =?ISO-8859-1?Q?Pe=F3n?= Costa" <carlospeon@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2556 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748Ab1KBSTx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 14:19:53 -0400
In-Reply-To: <SNT113-W38A7D5A673342F70A1F808DBD40@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-11-02 at 04:59 -0700, Carlos Pe=C3=B3n Costa wrote:
>=20
> Hi, It's a HP BL460c G6.
> Regards.

It looks like problem happened before the WATCHDOG, FW has asserted for
some reason.
Can you provide /var/log/messages and describe in details the scenario?
Thanks
