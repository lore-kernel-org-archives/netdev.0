From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Wed, 10 Nov 2004 02:10:41 +0100
Message-ID: <41916A91.3080107@trash.net>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041110010113.GJ31969@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>Sounds reasonable for the sch_api.c and cls_api.c case but
>will get very nasty for act_api as you noted and any further sub
>layers that might be added in the future. (The classifier I'm
>working on is such a case.)
>
Can you please show an example of a case where this is needed ?
Just to help me understand.

Regards
Patrick
