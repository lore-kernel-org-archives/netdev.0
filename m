From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [2.6 patch] appletalk: remove an unused function
Date: Thu, 28 Oct 2004 19:41:21 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041028234121.GA1539@havoc.gtf.org>
References: <20041028221046.GI3207@stusta.de> <20041028162643.2ee7e30e.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Adrian Bunk <bunk@stusta.de>, acme@conectiva.com.br, netdev@oss.sgi.com,
        linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20041028162643.2ee7e30e.davem@davemloft.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Oct 28, 2004 at 04:26:43PM -0700, David S. Miller wrote:
> On Fri, 29 Oct 2004 00:10:46 +0200
> Adrian Bunk <bunk@stusta.de> wrote:
> 
> > - -static inline void atalk_insert_socket(struct sock *sk)
> > - -{
> > - -	write_lock_bh(&atalk_sockets_lock);
> > - -	__atalk_insert_socket(sk);
> > - -	write_unlock_bh(&atalk_sockets_lock);
> > - -}
> > - -
> 
> This is a patch of a patch, I doubt it will apply cleanly ;-)

Ditto, all the patches sent to me look like this, too.

	Jeff
