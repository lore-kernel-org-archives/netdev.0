From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Null pointer dereference when bringing up bonding device on kernel-2.6.24-2.fc9.i686
Date: Thu, 31 Jan 2008 11:09:20 -0800
Message-ID: <14150.1201806560@death>
References: <m3bq75en2y.fsf@ursa.amorsen.dk> <7908.1201551451@death> <47A1C45C.5080906@p6drad-teel.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?us-ascii?Q?=3D=3FISO-8859-1=3FQ=3FSiim=5FP=3DF5der=3F=3D?=
	<siim@p6drad-teel.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:43677 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756558AbYAaTJY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 14:09:24 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0VJ9MSY017993
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 14:09:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0VJ9LOn239064
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 14:09:21 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0VJ9Ltw006711
	for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 14:09:21 -0500
In-reply-to: <47A1C45C.5080906@p6drad-teel.net> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Siim P=C3=B5der <siim@p6drad-teel.net> wrote:

>Jay Vosburgh wrote:
>> Benny Amorsen <benny+usenet@amorsen.dk> wrote:
>>=20
>>> https://bugzilla.redhat.com/show_bug.cgi?id=3D430391
>>=20
>> 	I know what this is, I'll fix it.
>
>do you know when this happend, so we would know which kernel is ok to
>use (not to start trying blindly)?

	It was something I changed up during the 2.6.24-rc development
somewhere.  Also, I posted the fix for this a couple days ago, it's
commit 5eb71eec3616b0a62e63197016576a74da240c6b in netdev-2.6#upstream.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
