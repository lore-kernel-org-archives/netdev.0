From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH resend 2] xen-netback: switch to threaded irq for control
 ring
Date: Thu, 22 Sep 2016 11:55:07 +0100
Message-ID: <20160922105507.GH27172@citrix.com>
References: <1474535185-15734-1-git-send-email-jgross@suse.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <wei.liu2@citrix.com>
To: Juergen Gross <jgross@suse.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:44969 "EHLO
        SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933521AbcIVKzO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 06:55:14 -0400
Content-Disposition: inline
In-Reply-To: <1474535185-15734-1-git-send-email-jgross@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 22, 2016 at 11:06:25AM +0200, Juergen Gross wrote:
> Instead of open coding it use the threaded irq mechanism in
> xen-netback.
> 
> Signed-off-by: Juergen Gross <jgross@suse.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
