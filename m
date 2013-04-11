From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] vxlan: Allow setting unicast address to the group address
Date: Thu, 11 Apr 2013 04:05:01 +0000 (UTC)
Message-ID: <kk5cpc$f14$1@ger.gmane.org>
References: <87txnen4y4.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:59118 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750792Ab3DKEFO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Apr 2013 00:05:14 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UQ8l4-0003y5-GS
	for netdev@vger.kernel.org; Thu, 11 Apr 2013 06:05:10 +0200
Received: from 221.11.29.155 ([221.11.29.155])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 06:05:10 +0200
Received: from xiyou.wangcong by 221.11.29.155 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 11 Apr 2013 06:05:10 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Apr 2013 at 08:52 GMT, Atzm Watanabe <atzm@stratosphere.co.jp> wrote:
> This patch allows setting unicast address to the VXLAN group address.
> It allows that VXLAN can be used as peer-to-peer tunnel without
> multicast.
>

Then GROUP is confusing, please pick another name and attribute.

Thanks.
