From: bora.sahin@ttnet.net.tr
Subject: Re: [PATCH 1/11] smc911x: Fix accessor SMC_* routines
Date: Tue, 12 Sep 2006 21:28:22 +0300
Message-ID: <200609122128.22375.bora.sahin@ttnet.net.tr>
References: <200609122032.47980.bora.sahin@ttnet.net.tr>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="Iso-8859-9"
Content-Transfer-Encoding: 7bit
Cc: Dustin McIntire <dustin@sensoria.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.ttnet.net.tr ([212.175.13.129]:11733 "EHLO
	fep05.ttnet.net.tr") by vger.kernel.org with ESMTP id S1030340AbWILSYC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Sep 2006 14:24:02 -0400
To: netdev@vger.kernel.org
In-Reply-To: <200609122032.47980.bora.sahin@ttnet.net.tr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> When in 16 bit mode, SMC_outl incorrectly simulates the situation and plus in 
> 32 bit mode SMC_outw is missing...
> 
[Snip]

Because mailer wraps the lines patch is not applied. I pushed it by mistake...

Sory for the inconsistencies. I'll cook up new series of patches...

--
Bora SAHIN
