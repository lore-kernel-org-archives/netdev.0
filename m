From: "David S. Miller" <davem@redhat.com>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Fri, 6 Feb 2004 19:53:25 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040206195325.207aa1c7.davem@redhat.com>
References: <20040115221841.7e7cc78d%hibi665@oki.com>
	<OFABEBA675.68903615-ON88256E33.000504D4-88256E33.0005673C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hibi665@oki.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFABEBA675.68903615-ON88256E33.000504D4-88256E33.0005673C@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 6 Feb 2004 18:01:37 -0700
David Stevens <dlstevens@us.ibm.com> wrote:

> +extern int is_mld(struct sk_buff *skb);

David, please don't pollute global name space so badly :-)
ipv6_is_mld() would be fine.
