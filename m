From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11-rc2] wireless: Make Atmel driver use	SET_NETDEV_DEV
Date: Tue, 01 Feb 2005 20:52:45 -0500
Message-ID: <4200326D.2000801@pobox.com>
References: <1107294126.17332.16.camel@dcbw.boston.redhat.com>	 <42002E00.6000101@pobox.com> <1107308462.20243.1.camel@dcbw.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, jgarzik@redhat.com, simon@thekelleys.org.uk
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1107308462.20243.1.camel@dcbw.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Dan Williams wrote:
> And both evolution and pine screw up the patches inline and break the
> line at odd places...  at least, that's what I see...  you don't mind if
> you have to do a little surgery here and there?

This is why we have request a common patch format -- because otherwise, 
everybody would request just-a-little-surgery-here-and-there.

It's much easier in the long run to get people to find solutions 
(pine+vi or mutt or Mozilla Mail) that work, than to hope that a 
maintainer will know and fix up each submittor's mailer's eccentricities.

	Jeff
