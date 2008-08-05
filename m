From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 0/2] replace dst_metric() with dst_mtu().
Date: Tue, 5 Aug 2008 15:59:09 +0300
Message-ID: <eb3ff54b0808050559s27be2d03qe689cc11ce3ac258@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.183]:57519 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759816AbYHEM7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2008 08:59:11 -0400
Received: by py-out-1112.google.com with SMTP id p76so1296848pyb.10
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 05:59:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
This patchset replaces dst_metric() with dst_mtu() in net/ipv4/route.c
and in net/ipv6/route.c.

Regards,
Rami Rosen
