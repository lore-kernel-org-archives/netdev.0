From: Andy King <acking@vmware.com>
Subject: Re: [PATCH net-next] VSOCK: Move af_vsock.h and vsock_addr.h to
 include/net
Date: Fri, 26 Jul 2013 08:41:38 -0700 (PDT)
Message-ID: <728438598.12051834.1374853298283.JavaMail.root@vmware.com>
References: <1374745174-9859-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>
To: Asias He <asias@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-2.vmware.com ([208.91.2.13]:41408 "EHLO
	smtp-outbound-2.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756379Ab3GZPli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jul 2013 11:41:38 -0400
In-Reply-To: <1374745174-9859-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> This is useful for other VSOCK transport implemented outside the
> net/vmw_vsock/ directory to use these headers.
> 
> Signed-off-by: Asias He <asias@redhat.com>

Acked-by: Andy King <acking@vmware.com>

Thanks for doing this!
- Andy
