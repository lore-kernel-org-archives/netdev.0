From: Christian Borntraeger <borntraeger@de.ibm.com>
Subject: Re: [PATCH] Virtual ethernet device (v2.1)
Date: Wed, 11 Jul 2007 12:54:24 +0200
Message-ID: <200707111254.24352.borntraeger@de.ibm.com>
References: <4694A363.2070406@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Daniel Lezcano <dlezcano@fr.ibm.com>,
	Ben Greear <greearb@candelatech.com>, devel@openvz.org,
	Kirill Korotaev <dev@openvz.org>
To: Pavel Emelianov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:46295 "EHLO
	mtagate2.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755169AbXGKKy2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2007 06:54:28 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l6BAsRbW220694
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 10:54:27 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l6BAsRcO2343090
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 11:54:27 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l6BAsQvB029340
	for <netdev@vger.kernel.org>; Wed, 11 Jul 2007 11:54:27 +0100
In-Reply-To: <4694A363.2070406@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am Mittwoch, 11. Juli 2007 schrieb Pavel Emelianov:
>  drivers/net/veth.c   |  452 
>  include/net/veth.h   |   14 +

I know, I am late in the game, but wont the name collide somewhat with 
drivers/net/ibmveth.h, drivers/net/iseries_veth.c, and drivers/net/ibmveth.c?

Christian
