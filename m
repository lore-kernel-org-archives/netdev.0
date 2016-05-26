From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net 0/4] net/mlx4_en: fix stats
Date: Thu, 26 May 2016 12:44:56 +0300
Message-ID: <271107bf-61b4-78ec-3c9a-4d57e88fad90@gmail.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36244 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750791AbcEZJpA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 05:45:00 -0400
Received: by mail-wm0-f65.google.com with SMTP id q62so3577706wmg.3
        for <netdev@vger.kernel.org>; Thu, 26 May 2016 02:44:59 -0700 (PDT)
In-Reply-To: <1464195039-5098-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

> mlx4 has various bugs in its ndo_get_stats() and related functions.
> This patch series address the obvious issues.
> Remaining ones will be discussed later.
>
Thanks for the fixes.
I see they were already applied.
I reviewed them all and replied to patch 4/4, the rest look good to me.
Please CC me as the maintainer of mlx4_en on future patches.

Regards,
Tariq
