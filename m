From: Patrick McHardy <kaber@trash.net>
Subject: Re: 2.6.8-rc4-bk1 problem: unregister_netdevice: waiting for ppp0
Date: Sun, 22 Aug 2004 17:50:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4128C0BB.9060503@trash.net>
References: <200408221504.i7MF4Z719895@d1o404.telia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Voluspa <lista4@comhem.se>
In-Reply-To: <200408221504.i7MF4Z719895@d1o404.telia.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Voluspa wrote:

>Greetings,
>
>NOTE
>I wrote the text below just prior to the posting of
>01-2.6-cbq-leaks.diff but applying it doesn't change the
>situation here. I still get the same Oops as below. Slight
>changes in memory address but the Call Trace is identical.
>So, different problem?
>ENDNOTE
>
Yes, your problem is a different one, but looks related to
the one in the thread "Oops: Process zebra, EIP is at
fib_create_info+0x22b/0x580".

Regards
Patrick
