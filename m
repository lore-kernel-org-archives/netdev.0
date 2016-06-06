From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: mlx4_en_netpoll() should schedule
 TX, not RX
Date: Mon, 6 Jun 2016 13:38:08 +0300
Message-ID: <e85b3fe6-3b55-7519-0956-3f9322952815@gmail.com>
References: <1464195039-5098-1-git-send-email-edumazet@google.com>
 <1464195039-5098-5-git-send-email-edumazet@google.com>
 <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
 <1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	=?UTF-8?Q?Maciej_=c5=bbenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:34653 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbcFFKiM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 06:38:12 -0400
Received: by mail-wm0-f65.google.com with SMTP id n184so15355666wmn.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 03:38:12 -0700 (PDT)
In-Reply-To: <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Eric.

> Totally untested patch, I would appreciate some feedback before merge,
> thanks !
I'm testing it, and will reply shortly.

Regards,
Tariq
