From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Re: [PATCH 2/2] xen-netfront: call netif_start_queue() on	xennet_open()
Date: Thu, 31 Jul 2008 13:09:01 -0700
Message-ID: <48921BDD.4050009@goop.org>
References: <1216912546-6971-1-git-send-email-ehabkost@redhat.com> <1216912546-6971-2-git-send-email-ehabkost@redhat.com> <4888A3B7.8060901@goop.org> <4888CA2A.1060509@garzik.org> <4888CC5D.9030800@goop.org> <20080731200323.GK7753@blackpad>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>,
	Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org,
	NetDev <netdev@vger.kernel.org>
To: Eduardo Habkost <ehabkost@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:35457 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753464AbYGaUJE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jul 2008 16:09:04 -0400
In-Reply-To: <20080731200323.GK7753@blackpad>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eduardo Habkost wrote:
> I didn't find it on any git repository. Is it queued somewhere? If not,
> should I resend?
>   

Yes, I think it fell through the cracks.  Resend to Jeff.

    J
