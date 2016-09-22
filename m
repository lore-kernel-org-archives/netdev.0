From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resend 2] xen-netback: switch to threaded irq for
 control ring
Date: Thu, 22 Sep 2016 08:26:48 -0400 (EDT)
Message-ID: <20160922.082648.746111486726375068.davem@davemloft.net>
References: <1474535185-15734-1-git-send-email-jgross@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, wei.liu2@citrix.com
To: jgross@suse.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1474535185-15734-1-git-send-email-jgross@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Juergen Gross <jgross@suse.com>
Date: Thu, 22 Sep 2016 11:06:25 +0200

> Instead of open coding it use the threaded irq mechanism in
> xen-netback.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>

Applied to net-next, thanks.
