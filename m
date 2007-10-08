From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 0/2] [AF_IUCV] fixes for net-2.6.24 - cleanup resend
Date: Mon, 08 Oct 2007 10:51:19 +0200
Message-ID: <20071008085119.805528000@linux.vnet.ibm.com>
Cc: heicars2@linux.vnet.ibm.com
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:39962 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752722AbXJHIzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 04:55:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-- 
Dave,

this is the resend of my patches from last week built against net-2.6.24.

> the following 2 patches are intended for 2.6.24 and contain:
> - removal of static declarations in af_iucv header file
> - postpone receival of inbound packets in af_iucv

Regards, Ursula
