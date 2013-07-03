From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: Move af_vsock.h and vsock_addr.h to include/net
Date: Wed, 03 Jul 2013 16:46:37 -0700 (PDT)
Message-ID: <20130703.164637.871965819487633272.davem@davemloft.net>
References: <1372816788-25548-1-git-send-email-asias@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, acking@vmware.com, dtor@vmware.com,
	grantr@vmware.com
To: asias@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39378 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932255Ab3GCXqk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 19:46:40 -0400
In-Reply-To: <1372816788-25548-1-git-send-email-asias@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Asias He <asias@redhat.com>
Date: Wed,  3 Jul 2013 09:59:48 +0800

> This is useful for other VSOCK transport implemented outside the
> net/vmw_vsock/ directory to use these headers.
> 
> Signed-off-by: Asias He <asias@redhat.com>

The merge window is closed and therefore new submissions like this
which are not bug fixes are not appropriate at this time.

Please resubmit this when the net-next tree opens again, which I
will announce here on netdev.
