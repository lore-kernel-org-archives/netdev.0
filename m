From: "David S. Miller" <davem@davemloft.net>
Subject: Re: IPv6 went away?
Date: Mon, 14 Mar 2005 15:01:51 -0800
Message-ID: <20050314150151.0a2abda6.davem@davemloft.net>
References: <42361510.2080902@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <42361510.2080902@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Mar 2005 17:49:52 -0500
Jeff Garzik <jgarzik@pobox.com> wrote:

> Has anything major been done to ipv6 recently?

Yes, it was changed with several updates from USAGI to
make it pass the "ipv6 ready" requirements.  The
experimental Kconfig tag was also removed, perhaps for this
reason it was not included in your build?
