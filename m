From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH v2 net-next 00/14] net: extend busy polling support
Date: Thu, 19 Nov 2015 08:09:07 +0200
Message-ID: <CAJ3xEMiUO_s1gHpQWb8e3FSFLyNn_Qxz5EmjMH0Hu=cn8FTbqQ@mail.gmail.com>
References: <1447857063-618-1-git-send-email-edumazet@google.com>
	<20151118.161826.1686345343654337694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:33073 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757782AbbKSGJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 01:09:08 -0500
Received: by iouu10 with SMTP id u10so80187269iou.0
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 22:09:07 -0800 (PST)
In-Reply-To: <20151118.161826.1686345343654337694.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015 at 11:18 PM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Wed, 18 Nov 2015 06:30:49 -0800

> I like this series a lot, and hope we can fix any fallout quickly and painlessly.
> Applied to net-next.

Hi Dave,

If you don't mind, next time we would be happy to get > 36h from the
initial post till patches
to the mlx4/5 drivers are applied, specifically when we have new
maintainers that have to catch
up, I know they should be learning to run fast on such cases... we
also didn't see a note from you
that the net-next / 4.5 window is open, so people here were under
wrong impression that that race
haven't been started.. anyway, could you please push that to your public git?

Or.
