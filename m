From: Jens Osterkamp <jens@de.ibm.com>
Subject: Re: [RFC][PATCH] spidernet: enable fiber autonegotiation
Date: Tue, 28 Nov 2006 10:18:11 +0100
Message-ID: <200611281018.13150.jens@de.ibm.com>
References: <OF866BFBF0.F4E98990-ON87257233.0069989E-86257233.006A0704@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: cbe-oss-dev@ozlabs.org, jgarzik@pobox.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([195.212.29.138]:6138 "EHLO
	mtagate5.uk.ibm.com") by vger.kernel.org with ESMTP id S935760AbWK1JSP
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Nov 2006 04:18:15 -0500
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate5.uk.ibm.com (8.13.8/8.13.8) with ESMTP id kAS9IEgB159176
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 09:18:14 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAS9L8rN2244622
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 09:21:08 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAS9IDJO027825
	for <netdev@vger.kernel.org>; Tue, 28 Nov 2006 09:18:13 GMT
To: James K Lewis <jklewis@us.ibm.com>
In-Reply-To: <OF866BFBF0.F4E98990-ON87257233.0069989E-86257233.006A0704@us.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


>   On my Cell blade this failed on the latest build (be0646). Running with
> the changes to sungem_phy does not allow the interfaces to ping anything.
> I went back to the original and everything works again. All I did was
> change sungem_phy and force it to be reloaded, let me know if I missed a
> step somewhere.

As I stated above, this is expected behaviour :

"This quick hack enables it with the sideeffect of breaking other bladecenter
switch configurations."

Jens
