From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [BK PATCHES] misc tg3 stuff
Date: Tue, 26 Oct 2004 11:55:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041026115555.390fcbbb.davem@davemloft.net>
References: <20041026165955.GA27136@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041026165955.GA27136@havoc.gtf.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 26 Oct 2004 12:59:55 -0400
Jeff Garzik <jgarzik@pobox.com> wrote:

> Please do a
> 
> 	bk pull bk://kernel.bkbits.net/jgarzik/tg3-2.6
> 
> This will update the following files:
> 
>  drivers/net/tg3.c |   22 +++++++++++-----------
>  1 files changed, 11 insertions(+), 11 deletions(-)

Your attached patch was full of e100 stuff and many
other totally unrelated changes, there were even crypto
layer diffs in there as well :-)

When you do range diffs with bitkeeper you have to
be really careful.
