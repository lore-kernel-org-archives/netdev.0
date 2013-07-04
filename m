From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] xfrm: replace xfrm_policy_afinfo_lock spinlock with mutex
Date: Thu, 4 Jul 2013 07:54:08 +0000 (UTC)
Message-ID: <kr39n0$veq$1@ger.gmane.org>
References: <1372920827-4144-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:32998 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755553Ab3GDHy0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Jul 2013 03:54:26 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UueMz-0005wc-A6
	for netdev@vger.kernel.org; Thu, 04 Jul 2013 09:54:25 +0200
Received: from 220.165.37.207 ([220.165.37.207])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 09:54:25 +0200
Received: from xiyou.wangcong by 220.165.37.207 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 09:54:25 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 04 Jul 2013 at 06:53 GMT, Fan Du <fan.du@windriver.com> wrote:
> Signed-off-by: Fan Du <fan.du@windriver.com>

Reason?
What problem did you meet?
