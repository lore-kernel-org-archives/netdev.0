From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: prevent user-space compilation errors
Date: Wed, 11 Feb 2004 22:02:32 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040211220232.7f54babc.davem@redhat.com>
References: <200402111425.i1BEPtRr005772@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com, huisheng@angelfire.com
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200402111425.i1BEPtRr005772@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 11 Feb 2004 09:25:57 -0500
chas williams (contractor) <chas@cmf.nrl.navy.mil> wrote:

> the script used by redhat to generate glibc-kernheaders doesnt
> seem to handle #ifdef __KERNEL__/#else/#endif properly. it seems
> to remove the #ifdef/#else and leaves a dangling #endif.
> 
> this patch simplifies things a bit.  please apply to 2.6 and 2.4.

Applied, thanks Chas.
