From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][INET] move inet_sock into inet_opt and rename it to
 inet_sock
Date: Mon, 27 Dec 2004 18:18:52 -0800
Message-ID: <20041227181852.036b6a62.davem@davemloft.net>
References: <41CE198B.7040005@conectiva.com.br>
	<200412272306.58203.acme@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <200412272306.58203.acme@conectiva.com.br>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 27 Dec 2004 23:06:57 -0200
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Dave, wait a while, I've just tried it with current BK, after Linus merged
> your 2.6.11 netdev queue and it breaks with things like Stephen's TCP
> ephemeral port changesets...

Ok, no problem.
