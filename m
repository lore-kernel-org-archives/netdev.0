From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: bind() use stronger condition for bind_conflict
Date: Wed, 28 Mar 2012 22:12:05 +0200
Message-ID: <1332965525.2325.13.camel@edumazet-glaptop>
References: <1332882712-10756-1-git-send-email-alex.mihai.c@gmail.com>
	 <20120328105212.1cb8dfe5@asterix.rh>
	 <1332946113.2325.9.camel@edumazet-glaptop>
	 <CAEnQRZD+0AQFfFCzWZCR5JR0BUxxNEsincD+_O9F0ne2Zryp_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Flavio Leitner <fbl@redhat.com>,
	Alexandru Copot <alex.mihai.c@gmail.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Daniel Baluta <dbaluta@ixiacom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAEnQRZD+0AQFfFCzWZCR5JR0BUxxNEsincD+_O9F0ne2Zryp_w@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2012-03-28 at 23:08 +0300, Daniel Baluta wrote:

> Eric, Flavio, thanks a lot for your comments. We will resubmit this
> when net-next opens.
> 
> Please let us know if you have any other observations.

Some performance data would be welcomed, in the case many sockets are
already bound...

Thanks
