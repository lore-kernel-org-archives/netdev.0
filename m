From: "Caitlin Bestler" <caitlinb@broadcom.com>
Subject: RE: TOE, etc.
Date: Wed, 28 Jun 2006 11:49:56 -0700
Message-ID: <54AD0F12E08D1541B826BE97C98F99F15F5B6D@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: herbert@gondor.apana.org.au, jgarzik@pobox.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:23052 "EHLO
	MMS3.broadcom.com") by vger.kernel.org with ESMTP id S1750975AbWF1SuF convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Jun 2006 14:50:05 -0400
Content-class: urn:content-classes:message
To: "David Miller" <davem@davemloft.net>, swise@opengridcomputing.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

netdev-owner@vger.kernel.org wrote:
> From: Steve Wise <swise@opengridcomputing.com>
> Date: Wed, 28 Jun 2006 09:54:57 -0500
> 
>> Doesn't iSCSI have this same issue?
> 
> Software iSCSI implementations don't have the issue because
> they go through the stack using normal sockets and normal
> device send and receive.

But hardware iSCSI implementations, which already exist,
do not work through normal sockets.

