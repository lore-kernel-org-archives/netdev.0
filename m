From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [patch] remove NETIF_F_TSO ifdefery
Date: Tue, 12 Dec 2006 08:05:46 -0800
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FDAE@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <457EAE1B.4070906@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4085 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751490AbWLLQF5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 11:05:57 -0500
Content-class: urn:content-classes:message
In-Reply-To: <457EAE1B.4070906@garzik.org>
To: "Jeff Garzik" <jeff@garzik.org>,
	"Arjan van de Ven" <arjan@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik write:

> Seems sane, though bnx2 and tg3 might want trivial modifications.  I 
> dunno if DaveM and mchan want to keep BCM_TSO and TG3_SUPPORT_TSO 
> defines (you kept them, I prefer to kill them).
> 

I agree with Jeff.  Those can be killed. 

