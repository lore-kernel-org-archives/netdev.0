From: "junk" <junk@toutatis.be>
Subject: skb_clone
Date: Thu, 17 Feb 2005 11:19:29 +0100
Message-ID: <20050217101331.M38167@toutatis.be>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=iso-8859-1
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,

i made a clone of a skb i catched with a netfilter hook.

Now i want to send that cloned skb on the wire.. what should i do? I tried
with dev_queue_xmit without success..
