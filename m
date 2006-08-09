From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: Bug report for MV643XX driver
Date: Wed, 9 Aug 2006 10:18:39 -0700
Message-ID: <20060809171839.GA12251@xyzzy.farnsworth.org>
References: <200608091047.28571.peloquin@mit.edu> <20060809162425.GA7464@xyzzy.farnsworth.org> <94266083-92C0-4771-8572-46C6B032E9EE@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dale Farnsworth <dale@farnsworth.org>, mlachwani@mvista.com,
	netdev@vger.kernel.org, josejx@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw-az.mvista.com ([65.200.49.142]:28680 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S1751271AbWHIRSk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 13:18:40 -0400
To: Stuart Peloquin <peloquin@MIT.EDU>
Content-Disposition: inline
In-Reply-To: <94266083-92C0-4771-8572-46C6B032E9EE@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 12:53:27PM -0400, Stuart Peloquin wrote:
> Hi Dale,
> 
> Thank you for responding quickly.
> 
> This is with gcc 4.1.1 and the config file has been added to the web  
> directory at http://web.mit.edu/peloquin/marvell/
> 
> Please let me know if I can provide anything else.

Can you test with an earlier version of the toolchain?  Maybe gcc-3.3?

Just this week I rebuilt a kernel for one of my Debian x86 server boxes
with gcc-4.1, and the tulip driver died early on.  When I rebuilt with
gcc-3.3, all was well.  I haven't had time to look for the details yet.

I'm not saying that gcc-4.1 is buggy, but this will help us narrow it
down.

BTW, I'm up against a deadline on another project, so I won't be able
to devote a lot of time to this today.

Thanks,
-Dale
