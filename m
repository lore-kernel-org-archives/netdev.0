From: Patrick McHardy <kaber@trash.net>
Subject: Re: request_module while holding rtnl semaphore
Date: Sun, 12 Dec 2004 19:04:09 +0100
Message-ID: <41BC8819.7040501@trash.net>
References: <41899DCF.3050804@trash.net> <E1CQDcP-0003ff-00@gondolin.me.apana.org.au> <20041109161126.376f755c.davem@davemloft.net> <20041110010113.GJ31969@postel.suug.ch> <41916A91.3080107@trash.net> <20041110012251.GK31969@postel.suug.ch> <41916F0B.5010809@trash.net> <20041110013941.GL31969@postel.suug.ch> <41917330.6090002@trash.net> <20041212175736.GA8493@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20041212175736.GA8493@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:

>I started working on a patchset to clean up all the error paths,
>allow changing all pararmeters for those not supporting it yet
>and to add the action bits for tcindex, route, and rsvp. Finishing
>it and writing all the test cases to do proper testing will take some
>time but I hope to have it ready for early 2.6.11 inclusion.
>
>Just to let you know so we don't do redundant work.
>
Thanks for the information. Next thing I want to do is clean up the
init paths and add proper error propagation.

Regards
Patrick
