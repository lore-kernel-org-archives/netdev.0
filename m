From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ATM]: [atmtcp] fix refcounting and vcc search
Date: Tue, 9 Nov 2004 16:19:59 -0800
Message-ID: <20041109161959.5ee5ad70.davem@davemloft.net>
References: <200411061338.iA6DcJTO017887@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
In-Reply-To: <200411061338.iA6DcJTO017887@ginger.cmf.nrl.navy.mil>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 06 Nov 2004 08:38:19 -0500
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> i must have been a bit confused when i originally converted this use
> the hash.  please apply to 2.6.
 ...
> Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>
 ...
> # ChangeSet
> #   2004/11/06 08:21:01-05:00 chas@relax.cmf.nrl.navy.mil 
> #   atmtcp.c:
> #     [ATM]: [atmtcp] fix refcounting and vcc search

Applied, thanks Chas.
