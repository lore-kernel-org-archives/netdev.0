From: Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au>
Subject: Re: r8169 - panic and a fix
Date: Tue, 14 Sep 2004 00:16:00 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200409140016.01028.sriharivijayaraghavan@yahoo.com.au>
References: <200409082224.23829.sriharivijayaraghavan@yahoo.com.au> <200409121832.57233.sriharivijayaraghavan@yahoo.com.au> <20040912231516.GA27299@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20040912231516.GA27299@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 13 Sep 2004 09:15 am, Francois Romieu wrote:
> Srihari Vijayaraghavan <sriharivijayaraghavan@yahoo.com.au> :
> ...
> Can you #define RX_BUF_SIZE 3072 and run with r8169-dbg-b applied ?
>

That does not help. It hangs on a first ping from a remote machine.

There is no OOPS or BUG or panic and it simply hard locks. No sysrq either.
(Pressing the power switch was the only option.)

Thank you.
Hari.
