From: Patrick McHardy <kaber@trash.net>
Subject: Re: patch: Action repeat
Date: Sat, 30 Apr 2005 19:08:58 +0200
Message-ID: <4273BBAA.6060405@trash.net>
References: <1114879817.8929.117.camel@localhost.localdomain> <4273BB30.1050402@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@oss.sgi.com>, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: hadi@cyberus.ca
In-Reply-To: <4273BB30.1050402@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> I have a question regarding tcf_action_init() and skb->tc_classid.
> tcf_action_init() overrides the classification result with

That should be tcf_action_exec(), sorry.
