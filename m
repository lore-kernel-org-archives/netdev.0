From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [SUNGEM] add tx_lock
Date: Wed, 15 Sep 2004 08:33:25 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040915083325.1c6757ec.davem@davemloft.net>
References: <5cac192f040914234361e1b929@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Lemoine <eric.lemoine@gmail.com>
In-Reply-To: <5cac192f040914234361e1b929@mail.gmail.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 15 Sep 2004 08:43:39 +0200
Eric Lemoine <eric.lemoine@gmail.com> wrote:

> The attached patch makes SunGEM NAPI driver in conformance to tg3 and
> e1000 in terms of locking logic. Applies to current BK:net-2.6.

Applied, thanks Eric.
