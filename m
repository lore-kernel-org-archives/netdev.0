From: Jason Lunz <lunz@falooley.org>
Subject: Re: double-check me?
Date: Mon, 18 Aug 2003 14:38:50 +0000 (UTC)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <slrnbk1p7n.306.lunz@absolut.localnet>
References: <3F3FBF50.8070207@pobox.com> <m3n0e8uhl4.fsf@defiant.pm.waw.pl> <3F400226.1080006@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

jgarzik@pobox.com said:
> C pointer arithmatic.  Ok, duh, thanks :)
> 	Jeff, too used to void pointer arith

Don't get _too_ used to it. arithmetic on (void *) is a gcc extension.
it's undefined in ansi C.

Jason
