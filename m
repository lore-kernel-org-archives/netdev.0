From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM] minor cleanups for 2.5
Date: Mon, 21 Jul 2003 05:24:16 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030721052416.3ef97f3b.davem@redhat.com>
References: <200307162120.h6GLKWsG023003@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200307162120.h6GLKWsG023003@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 17:18:04 -0400
chas williams <chas@cmf.nrl.navy.mil> wrote:

> (and how does __inline__ work
> when its the timer function?)

If you take the address of a function marked inline,
gcc outputs a non-inline of the function.

All of your ATM patches applied, thanks Chas.
