From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: [PATCH 2/3] r8169: code clean-up
Date: Sun, 20 Feb 2005 12:14:15 -0600
Message-ID: <200502201214.15884.jdmason@us.ibm.com>
References: <200502161823.43562.jdmason@us.ibm.com> <20050217232804.GA4992@electric-eye.fr.zoreil.com> <4218CE73.6010206@phekda.gotadsl.co.uk>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@oss.sgi.com
To: Richard Dawe <rich@phekda.gotadsl.co.uk>
In-Reply-To: <4218CE73.6010206@phekda.gotadsl.co.uk>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sunday 20 February 2005 11:52 am, Richard Dawe wrote:
> Hello.
>
> Francois Romieu wrote:
> > Jon Mason <jdmason@us.ibm.com> :
>
> [snip]
>
> >>adds a link down notification, and cleans up
> >
> > Ok. I'll netif_msg it before someone else complains that the driver
> > is too verbose.
>
> [snip]
>
> I started working on adding netif_msg checks to the printks. How far
> have you got? I don't want to duplicate your work.
>
> Incidentally, is there a to-do list somewhere for the r8169 driver?

Not to my knowledge.  It would be nice if there was a wiki out there which 
lists all of the drivers and areas to work on (features enablement, open 
bugs, etc.)

> Maybe I can help out with some of the things.

I know Francois likes it when people test his patches.  :-)

> Thanks, bye, Rich =]
