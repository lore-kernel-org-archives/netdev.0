From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETLINK] introduce netlink bucket
Date: Tue, 2 Nov 2004 14:16:56 -0800
Message-ID: <20041102141656.197d657f.davem@davemloft.net>
References: <E1CP6wn-0003VF-00@gondolin.me.apana.org.au>
	<4188088D.4040506@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4188088D.4040506@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 02 Nov 2004 23:22:05 +0100
Pablo Neira <pablo@eurodev.net> wrote:

> uh just curious, what kind of patches?

Herbert and I have a pending patch which changes the code over
to use hash lookups for the "find socket by PID" netlink
code.
