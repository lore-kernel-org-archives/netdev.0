From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: double-check me?
Date: Mon, 18 Aug 2003 10:41:19 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030818144119.GA24693@gtf.org>
References: <3F3FBF50.8070207@pobox.com> <m3n0e8uhl4.fsf@defiant.pm.waw.pl> <3F400226.1080006@pobox.com> <slrnbk1p7n.306.lunz@absolut.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jason Lunz <lunz@falooley.org>
Content-Disposition: inline
In-Reply-To: <slrnbk1p7n.306.lunz@absolut.localnet>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, Aug 18, 2003 at 02:38:50PM +0000, Jason Lunz wrote:
> jgarzik@pobox.com said:
> > C pointer arithmatic.  Ok, duh, thanks :)
> > 	Jeff, too used to void pointer arith
> 
> Don't get _too_ used to it. arithmetic on (void *) is a gcc extension.
> it's undefined in ansi C.

Yes, I know.

It's used extensively in the kernel, however.

	Jeff
