From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH net-next] net/mlx4_en: mlx4_en_netpoll() should schedule
 TX, not RX
Date: Thu, 9 Jun 2016 13:48:31 +0300
Message-ID: <5150feda-7606-6aec-1c90-9cef94b9c05d@gmail.com>
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
Received: from mail-wm0-f50.google.com ([74.125.82.50]:35698 "EHLO
	mail-wm0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932143AbcFIKsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 06:48:35 -0400
Received: by mail-wm0-f50.google.com with SMTP id v199so101470057wmv.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 03:48:35 -0700 (PDT)
In-Reply-To: <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Acked-by: Tariq Toukan <tariqt@mellanox.com>
