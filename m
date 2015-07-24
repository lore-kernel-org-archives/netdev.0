From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH]mlx4-core: fix possible use after free in cq_completion
Date: Fri, 24 Jul 2015 22:22:42 +0300
Message-ID: <CAJ3xEMit4eFTp_eNL-pq83gEjx2d_7NTiKXtyYkEjBo1K_=u0w@mail.gmail.com>
References: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jack Morgenstein <jackm@dev.mellanox.co.il>,
	Yun Wang <yun.wang@profitbricks.com>,
	"talal@mellanox.com" <talal@mellanox.com>
To: Jinpu Wang <jinpu.wang@profitbricks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:32874 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753197AbbGXTWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 15:22:43 -0400
Received: by oige126 with SMTP id e126so24534939oig.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 12:22:42 -0700 (PDT)
In-Reply-To: <CAMGffEnvM32Ae-XHDLuwGy1V7NKqosO+eAtakbKJCcVpqKQg3Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2015 at 11:18 AM, Jinpu Wang
<jinpu.wang@profitbricks.com> wrote:
> I hit bug in OFED, I report to link below:
> http://marc.info/?l=linux-rdma&m=143634872328553&w=2
> I checked latest mainline Linux 4.2-rc3, it has similar bug.
> Here is the patch against Linux 4.2-rc3, compile test only.

Did you see the bug hitting and the fix in action over upstream?! if
not, it would be very helpful if you do so. Anyway, I'll ask Jack to
look on that next week.

Or.
