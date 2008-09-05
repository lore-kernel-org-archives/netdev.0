From: =?ISO-8859-1?Q?Dan_No=E9?= <dnoe@limebrokerage.com>
Subject: TCP stateless offload with bonding?
Date: Fri, 05 Sep 2008 12:04:21 -0400
Message-ID: <48C15885.9050908@limebrokerage.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.limebrokerage.com ([64.111.220.126]:56822 "EHLO
	infra1-jc.limebrokerage.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750885AbYIEQOb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2008 12:14:31 -0400
Received: from [10.12.20.122] (rockhopper.limebrokerage.com [10.12.20.122])
	by infra1-jc.limebrokerage.com (Postfix) with ESMTP id 8DD9719A157
	for <netdev@vger.kernel.org>; Fri,  5 Sep 2008 12:04:22 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Documentation/networking/bonding.txt file talks about VLAN offload=20
support and the bonding driver, but not TCP segmentation, UDP/TCP=20
checksum, etc, offloading.  Is this supported by the bonding driver, an=
d=20
if so, how is it configured?

If it matters, we are using bonding for HA/failover, not for bandwidth=20
aggregation.

Thanks!

Cheers,
Dan

--=20
Dan No=E9
Software Engineer
Lime Brokerage LLC
781-370-2518
