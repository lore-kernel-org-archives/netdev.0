From: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Subject: Re: [PATCH][ATM]: [drivers] fix warnings related to readl/writel changes
Date: Tue, 21 Sep 2004 18:03:06 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409212203.i8LM35TG012489@ginger.cmf.nrl.navy.mil>
References: <davem@davemloft.net>
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: Message from "David S. Miller" <davem@davemloft.net>
   of "Tue, 21 Sep 2004 14:49:20 PDT." <20040921144920.7e62ca9e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

thanks! i missed that bit.

In message <20040921144920.7e62ca9e.davem@davemloft.net>,"David S. Miller" writ
es:
>Applied, then I added a further patch on top of this
>one which uses the correct "void __iomem *" for these
>things, as follows.
