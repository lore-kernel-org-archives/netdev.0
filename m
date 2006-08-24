From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH][REPOST] WAN: fix C101 card carrier handling
Date: Thu, 24 Aug 2006 15:26:19 +0200
Message-ID: <m3fyfmp8n8.fsf@defiant.localdomain>
References: <m3k651udsq.fsf@defiant.localdomain> <44ED1F88.20304@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:11973 "EHLO khc.piap.pl")
	by vger.kernel.org with ESMTP id S1751727AbWHXN0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2006 09:26:22 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <44ED1F88.20304@garzik.org> (Jeff Garzik's message of "Wed, 23 Aug 2006 23:39:52 -0400")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik <jeff@garzik.org> writes:

>> One of my recent changes broke C101 carrier handling, this patch
>> fixes it. Also fixes an old TX underrun checking bug.
>> 2.6.18 material. Please apply.
>
> it's already in netdev-2.6.git#upstream-fixes, destined for 2.6.18.

Great, I somehow missed it. Thank you.
-- 
Krzysztof Halasa
