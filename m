From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH]: fix queue limits in multiple qdiscs
Date: Mon, 17 Nov 2003 15:47:59 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3FB8DF9F.7030509@trash.net>
References: <3FB39A2D.5020000@trash.net> <1069076955.1076.23.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <1069076955.1076.23.camel@jzny.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I don't have strong feelings about this, I just kept wondering why tc
displayes "pfifo limit 10 backlog 11".

Best regards,
Patrick

jamal wrote:

>valid but Too cosmetic, IMO; (who cares when you are off by a few
>bytes?)
>
>cheers,
>jamal
>
