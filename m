From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 0/2] [IPV4] [NETFILTER] Misc Cleanups.
Date: Mon, 2 Jun 2008 09:36:35 +0300
Message-ID: <eb3ff54b0806012336s687b0d89t767c31615d955c61@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.230]:56122 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751110AbYFBGgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jun 2008 02:36:35 -0400
Received: by rv-out-0506.google.com with SMTP id l9so907782rvb.1
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2008 23:36:35 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
  While probing into IPV4 netfilter code, I came across these cleanups in
  net/ipv4/netfilter/ip_queue.c and in
include/net/netfilter/ipv4/nf_conntrack_ipv4.h.

Regards,
Rami Rosen


Signed-off-by: Rami Rosen <ramirose@gmail.com>
