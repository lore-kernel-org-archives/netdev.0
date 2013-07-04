From: Asias He <asias@redhat.com>
Subject: Re: [PATCH] VSOCK: Move af_vsock.h and vsock_addr.h to include/net
Date: Thu, 4 Jul 2013 08:42:43 +0800
Message-ID: <20130704004243.GA19213@hj.localdomain>
References: <1372816788-25548-1-git-send-email-asias@redhat.com>
 <20130703.164637.871965819487633272.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, acking@vmware.com, dtor@vmware.com,
	grantr@vmware.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17669 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755247Ab3GDAmq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Jul 2013 20:42:46 -0400
Content-Disposition: inline
In-Reply-To: <20130703.164637.871965819487633272.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 03, 2013 at 04:46:37PM -0700, David Miller wrote:
> From: Asias He <asias@redhat.com>
> Date: Wed,  3 Jul 2013 09:59:48 +0800
> 
> > This is useful for other VSOCK transport implemented outside the
> > net/vmw_vsock/ directory to use these headers.
> > 
> > Signed-off-by: Asias He <asias@redhat.com>
> 
> The merge window is closed and therefore new submissions like this
> which are not bug fixes are not appropriate at this time.
> 
> Please resubmit this when the net-next tree opens again, which I
> will announce here on netdev.

Sure. This is a very low priority patch. Will resubmit.

Thanks.
-- 
Asias
