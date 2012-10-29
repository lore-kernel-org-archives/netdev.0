From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH net-next] ipv6: remove useless test in
 dev_forward_change()
Date: Mon, 29 Oct 2012 09:22:21 +0000 (UTC)
Message-ID: <k6lhsd$jui$1@ger.gmane.org>
References: <20121029015709.GA18567@localhost>
 <1351502649-3876-1-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:56210 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751664Ab2J2JWe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Oct 2012 05:22:34 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1TSlYO-0005iu-Io
	for netdev@vger.kernel.org; Mon, 29 Oct 2012 10:22:40 +0100
Received: from 112.132.138.96 ([112.132.138.96])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 10:22:40 +0100
Received: from xiyou.wangcong by 112.132.138.96 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 10:22:40 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 29 Oct 2012 at 09:24 GMT, Nicolas Dichtel <nicolas.dichtel@6wind.com> wrote:
> idev->dev cannot be NULL.
>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

I sent a same patch before you:

http://marc.info/?l=linux-netdev&m=135148225303417&w=2

:)
