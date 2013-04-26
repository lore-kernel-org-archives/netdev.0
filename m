From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V3 5/5] net/mlx4_en: Add a service task
Date: Thu, 25 Apr 2013 19:39:08 -0700
Message-ID: <1366943948.8964.185.camel@edumazet-glaptop>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
	 <1366733211-10228-6-git-send-email-amirv@mellanox.com>
	 <1366935188.8964.183.camel@edumazet-glaptop>
	 <CAJZOPZLFtgVzk0YTzDkq1pGife6xTGH8tRtMYK=9nsTZFZmwQg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Vadai <amirv@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f54.google.com ([209.85.210.54]:41016 "EHLO
	mail-da0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757190Ab3DZCjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 22:39:11 -0400
Received: by mail-da0-f54.google.com with SMTP id s35so1702367dak.27
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 19:39:10 -0700 (PDT)
In-Reply-To: <CAJZOPZLFtgVzk0YTzDkq1pGife6xTGH8tRtMYK=9nsTZFZmwQg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-04-26 at 05:24 +0300, Or Gerlitz wrote:

> Hi Eric,
> 
> This is fixed in "[PATCH V1 net-next 2/8] net/mlx4_en: Disable HW
> clock overflow check when no HW support"
> http://marc.info/?l=linux-netdev&m=136690338314540&w=2
> 

OK thanks, I missed it because the patch serie had the following label :

"[PATCH V1 net-next 0/8] net/mlx4: Add support to SRIOV VF management
ndo calls"
