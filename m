From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] change the default Kconfig value of mlx5_en
Date: Fri, 21 Apr 2017 15:47:45 -0400 (EDT)
Message-ID: <20170421.154745.182611990085743539.davem@davemloft.net>
References: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org
To: ian.kumlien@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37758 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425472AbdDUTrr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:47:47 -0400
In-Reply-To: <CAA85sZumYPfUg_yA=5azrHneqq-XBmHiGNgRaEvBwbewVRj11w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ian Kumlien <ian.kumlien@gmail.com>
Date: Fri, 21 Apr 2017 21:45:00 +0200

> The mellanox driver supports both ethernet and infiniband, but it
> is located in the ethernet drivers - the ethernet support should
> default to 'yes'.

I don't have that card and I therefore perhaps don't want that driver
in my builds.

This is not an appropriate change, sorry.
