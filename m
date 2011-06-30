From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] Exclude duplicated checking for iface-up. This flags is
 checked in 'is_skb_forwardable' function, which is subroutine of
 'dev_forward_skb'.
Date: Thu, 30 Jun 2011 12:07:52 +0000 (UTC)
Message-ID: <iuhouo$fid$2@dough.gmane.org>
References: <1309267844-29334-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:37977 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752565Ab1F3MIJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2011 08:08:09 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QcG2Q-0005pV-Hm
	for netdev@vger.kernel.org; Thu, 30 Jun 2011 14:08:06 +0200
Received: from 123.124.21.94 ([123.124.21.94])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 14:08:06 +0200
Received: from xiyou.wangcong by 123.124.21.94 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2011 14:08:06 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 28 Jun 2011 17:30:44 +0400, alex.bluesman.smirnov wrote:

> From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> 

Please add the description here, instead of in $subject.

> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
> ---

The patch itself looks fine,

Reviewed-by: WANG Cong <xiyou.wangcong@gmail.com>

Thanks.

