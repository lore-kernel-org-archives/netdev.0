From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: TOE, etc.
Date: Wed, 28 Jun 2006 17:10:08 -0400
Message-ID: <44A2F030.4080102@pobox.com>
References: <54AD0F12E08D1541B826BE97C98F99F15F5B6D@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, swise@opengridcomputing.com,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:33493 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751529AbWF1VKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2006 17:10:14 -0400
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F15F5B6D@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caitlin Bestler wrote:
> netdev-owner@vger.kernel.org wrote:
>> From: Steve Wise <swise@opengridcomputing.com>
>> Date: Wed, 28 Jun 2006 09:54:57 -0500
>>
>>> Doesn't iSCSI have this same issue?
>> Software iSCSI implementations don't have the issue because
>> they go through the stack using normal sockets and normal
>> device send and receive.
> 
> But hardware iSCSI implementations, which already exist,
> do not work through normal sockets.

No, they work through normal SCSI stack...

	Jeff



