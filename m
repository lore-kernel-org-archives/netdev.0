From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH] atm/eni: use skb_queue_walk, not open coded equivalent
Date: Sun, 17 Aug 2003 23:34:36 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030817233436.7588bb1b.davem@redhat.com>
References: <20030818030859.GB2853@conectiva.com.br>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
In-Reply-To: <20030818030859.GB2853@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 18 Aug 2003 00:08:59 -0300
Arnaldo Carvalho de Melo <acme@conectiva.com.br> wrote:

> Hi Chas, David,
> 
> 	Pleae consider pulling from:
> 
> bk://kernel.bkbits.net/acme/sk_buff-2.6
> 
> 	There is just this trivial outstanding changeset there.

Pulled, thanks Arnaldo.
