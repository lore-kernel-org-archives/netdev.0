From: "David S. Miller" <davem@davemloft.net>
Subject: Re: Tons of "BUG: dst overflow ..." messages
Date: Tue, 28 Sep 2004 21:40:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040928214055.609f7715.davem@davemloft.net>
References: <415A3635.4070000@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <415A3635.4070000@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 29 Sep 2004 00:12:37 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> BUG: dst underflow 0: cf5dd180 at f8c0be5d
> BUG: dst underflow 0: cf5dd180 at f8c0d15c
> BUG: dst underflow 0: cf5dd180 at f8c1656f

Can you match up the 0xf8xxxxxx addresses to spots
in your System.map?  Thanks.
