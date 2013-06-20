From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 2/4] VSOCK: Return VMCI_ERROR_NO_MEM when fails to
 allocate skb
Date: Thu, 20 Jun 2013 08:15:27 -0700 (PDT)
Message-ID: <1896696532.3266996.1371741327883.JavaMail.root@vmware.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com> <1371720033-19714-3-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>
To: Asias He <asias@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:41142 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757710Ab3FTPZU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Jun 2013 11:25:20 -0400
In-Reply-To: <1371720033-19714-3-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> vmci_transport_recv_dgram_cb always return VMCI_SUCESS even if we fail
> to allocate skb, return VMCI_ERROR_NO_MEM instead.
> 
> Signed-off-by: Asias He <asias@redhat.com>

Acked-by: Andy King <acking@vmware.com>

Thanks!
- Andy
