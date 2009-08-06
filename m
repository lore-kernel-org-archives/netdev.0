From: Hannes Hering <hannes.hering@gmx.de>
Subject: Re: system hangs while executing 'rmmod ehea'
Date: Thu, 6 Aug 2009 10:33:57 +0200
Message-ID: <200908061033.57696.hannes.hering@gmx.de>
References: <4A699E70.2090900@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, HERING2@de.ibm.com, THEMANN@de.ibm.com,
	TKLEIN@de.ibm.com
To: Pavan Naregundi <pavan@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8.uk.ibm.com ([195.212.29.141]:56514 "EHLO
	mtagate8.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754542AbZHFIep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 04:34:45 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate8.uk.ibm.com (8.14.3/8.13.8) with ESMTP id n768XwBZ739936
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 08:33:59 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n768XwBw962714
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 09:33:58 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n768Xwqx015432
	for <netdev@vger.kernel.org>; Thu, 6 Aug 2009 09:33:58 +0100
In-Reply-To: <4A699E70.2090900@linux.vnet.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

this problem has been fixed by a patch I sent out on tuesday:
http://lkml.org/lkml/2009/8/4/174

Thanks for pointing out this.

Regards

Hannes
