From: Andy King <acking@vmware.com>
Subject: Re: [PATCH 4/4] VSOCK: Fix VSOCK_HASH and VSOCK_CONN_HASH
Date: Fri, 21 Jun 2013 05:48:20 -0700 (PDT)
Message-ID: <1045033957.4517542.1371818900042.JavaMail.root@vmware.com>
References: <1371720033-19714-1-git-send-email-asias@redhat.com> <1371720033-19714-5-git-send-email-asias@redhat.com> <783609149.3265072.1371741133384.JavaMail.root@vmware.com> <20130621002201.GA11759@hj.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Dmitry Torokhov <dtor@vmware.com>,
	Reilly Grant <grantr@vmware.com>
To: Asias He <asias@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-outbound-1.vmware.com ([208.91.2.12]:59412 "EHLO
	smtp-outbound-1.vmware.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S965608Ab3FUMsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Jun 2013 08:48:21 -0400
In-Reply-To: <20130621002201.GA11759@hj.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> [0-250] is for bound sockets, [251] is for unbound sockets, no?

Well caught.

Acked-by: Andy King <acking@vmware.com>

Thanks!
- Andy
