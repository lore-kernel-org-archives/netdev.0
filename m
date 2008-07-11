From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: bridging with gre tunnel
Date: Fri, 11 Jul 2008 09:30:08 +0300
Message-ID: <4876FDF0.1030807@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: bridge@lists.linux-foundation.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:36381 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500AbYGKGaB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2008 02:30:01 -0400
Received: by ug-out-1314.google.com with SMTP id h2so36084ugf.16
        for <netdev@vger.kernel.org>; Thu, 10 Jul 2008 23:29:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

It looks the current kernel still do not support bridging over gre
tunnels.

I did find an old patch for ip_gre that would enable this [1]. But
it needs porting from 2.4 to 2.6 kernels and looks like it needs
cleaning up too.

Is there newer/better patches to achieve this? Any thoughts about
doing bridging with gre tunnels?

Cheers,
  Timo

[1] http://mailman.ds9a.nl/pipermail/lartc/2003q4/010327.html
