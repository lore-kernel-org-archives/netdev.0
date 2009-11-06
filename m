From: Francis Moreau <francis.moro@gmail.com>
Subject: Re: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct
Date: Fri, 6 Nov 2009 09:45:01 +0100
Message-ID: <38b2ab8a0911060045hb6ebab8p43bf8aa838eabfd3@mail.gmail.com>
References: <38b2ab8a0909290109m3f82c161j4fb0f1266152877e@mail.gmail.com>
	 <4AC1D0F5.4050709@gmail.com>
	 <38b2ab8a0910300144i7a3c190fi9aa3d079c9cdb754@mail.gmail.com>
	 <4AEACD88.8080108@gmail.com> <4AEB0059.1050400@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755475AbZKFIo7@vger.kernel.org>
In-Reply-To: <4AEB0059.1050400@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Oct 30, 2009 at 4:03 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:

[...]

>
> [PATCH take2] net: fix sk_forward_alloc corruption
>

With this patch applied 4 days ago, I haven't got any oops so far.
-- 
Francis
