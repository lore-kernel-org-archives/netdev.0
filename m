From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH][ATM]: [drivers] use msleep() instead of
 schedule_timeout() (from Nishanth Aravamudan <nacc@us.ibm.com>)
Date: Tue, 21 Sep 2004 15:18:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040921151801.3ccd21cd.davem@davemloft.net>
References: <200409212029.i8LKTINv010576@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, netdev@oss.sgi.com, davem@redhat.com,
        nacc@us.ibm.com, kernel-janitors@lists.osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: chas3@users.sourceforge.net
In-Reply-To: <200409212029.i8LKTINv010576@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 21 Sep 2004 16:29:19 -0400
"chas williams (contractor)" <chas@cmf.nrl.navy.mil> wrote:

> this patch (from nacc@us.ibm.com) replaces assorted schedule_timeout()'s
> with msleep()'s.  please apply to 2.6.

Applied, thanks Chas and Nishanth.
