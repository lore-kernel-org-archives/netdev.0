From: "David S. Miller" <davem@davemloft.net>
Subject: Re: fib route create slow
Date: Sat, 28 Aug 2004 22:21:21 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040828222121.742b6225.davem@davemloft.net>
References: <20040829033115.GA6467@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Benjamin LaHaise <bcrl@kvack.org>
In-Reply-To: <20040829033115.GA6467@kvack.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 28 Aug 2004 23:31:16 -0400
Benjamin LaHaise <bcrl@kvack.org> wrote:

>   1820 fib_create_info                            1.6978
>   2976 fib_sync_down                             18.6000
>   7026 total                                      0.0041

This'll get fixed in the next month or so, promise.
