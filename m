From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [patch] Added TCP sysctl tunables.
Date: Tue, 28 May 2013 00:44:58 +0000 (UTC)
Message-ID: <ko0um9$hkd$1@ger.gmane.org>
References: <5197C327.1030806@yandex-team.ru>
 <51A38D09.4080600@yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56186 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758405Ab3E1ApS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 May 2013 20:45:18 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1Uh82O-0001ze-Pw
	for netdev@vger.kernel.org; Tue, 28 May 2013 02:45:16 +0200
Received: from 180.183.220.200 ([180.183.220.200])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 02:45:16 +0200
Received: from xiyou.wangcong by 180.183.220.200 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 28 May 2013 02:45:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 May 2013 at 16:42 GMT, Denis Zaitsev <dzaitsev@yandex-team.ru> wrote:
> Hi again.
> It seems, you all were too busy and forgot about this email. So I'm
> writing again : )
>

First, your patch is corrupted, tab's are gone.

Second, one patch for one feature please.

Third, the delayed ACK heuristic is rejected by upstream, try
to search email archive for more details, I have a patch for
per-route delayed ACK interface (will post soon).
