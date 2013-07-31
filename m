From: Or Gerlitz <or.gerlitz@gmail.com>
Subject: duplicate mlx5 patch in the net and ib trees
Date: Wed, 31 Jul 2013 23:33:16 +0300
Message-ID: <CAJZOPZKJESnXo5FjOMSn5-KGibJWbnFpFt5-1UyagOBNUgo62w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Roland Dreier <roland@kernel.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:41267 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757210Ab3GaUdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 16:33:17 -0400
Received: by mail-qc0-f176.google.com with SMTP id u12so638967qcx.35
        for <netdev@vger.kernel.org>; Wed, 31 Jul 2013 13:33:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Roland, "mlx5_core: Fix error return code in mlx5_alloc_uuars" is both
in your for-next branch and Dave's net tree.  Probably the best way to
handle that would be for you to drop it over from that branch before
you send the pull request, as too many people have clones of net.

Or.
