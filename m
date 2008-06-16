From: "Rami Rosen" <ramirose@gmail.com>
Subject: [PATCH net-2.6 0/2] tcp: minor cleanups.
Date: Mon, 16 Jun 2008 12:06:03 +0300
Message-ID: <eb3ff54b0806160206x66cf3294n3ec973de0f100c4e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.173]:39689 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756397AbYFPJGE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 05:06:04 -0400
Received: by wf-out-1314.google.com with SMTP id 27so5125305wfd.4
        for <netdev@vger.kernel.org>; Mon, 16 Jun 2008 02:06:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

 While probing into tcp code,  I came across these minor cleanups in
 tcp_ipv4.c and in tcp_ipv6.c.

Regards,
Rami Rosen

Signed-off-by: Rami Rosen <ramirose@gmail.com>
