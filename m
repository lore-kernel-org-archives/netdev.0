From: Asdo <asdo@shiftmail.org>
Subject: Re: TCP sockets stalling - help! (long)
Date: Wed, 25 Nov 2009 14:07:26 +0100
Message-ID: <4B0D2C0E.9050101@shiftmail.org>
References: <4B0CB1B8.8030402@shiftmail.org>
	<alpine.DEB.2.00.0911251344520.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: e1000-devel@lists.sourceforge.net, Netdev <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-reply-to: <alpine.DEB.2.00.0911251344520.7024@wel-95.cs.helsinki.fi>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> ...I'd next try strace the sftp server to see what it was doing =

> during the stall.
>   =

Thanks for your help Ilpo

Isn't the strace equivalent to the stack trace I obtained via cat =

/proc/pid/stack reported previously? That was at the time of the stall

I'm thinking the strace would slow down sftp-server very deeply...



---------------------------------------------------------------------------=
---
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day =

trial. Simplify your report design, integration and deployment - and focus =
on =

what you do best, core application coding. Discover what's new with
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
