From: Lawrence Walton <lawrence@the-penguin.otak.com>
Subject: Re: SysKonnect sk98lin Gigabit lan missing in action from 2.6.10 on
Date: Fri, 4 Feb 2005 14:28:26 -0800
Message-ID: <20050204222825.GA8533@the-penguin.otak.com>
References: <42038994.20401@xmission.com> <4203E3FE.2090806@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4203E3FE.2090806@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik [jgarzik@pobox.com] wrote:
> maxer wrote:
> >What is the status of sk98lin? Do we have to wait until Syskonnect gets 
> >their act together
> >and write a new driver for 2.6.10?
> >
> >Their latest is Oct 2004 and not at all compatible with 2.6.10 and beyond.
> 
> I've been telling SysKonnect for _years_ that they need to split up 
> their patches, but they still keep sending ever-larger jumbo driver 
> update patches.
> 
> Stephen Hemminger split up their patch into a bunch of patches, and I 
> applied several of those.
> 
> Apparently, Stephen also got sick of trying to patch and clean sk98lin, 
> so he went and wrote his own "skge" driver.  It's available in my 
> netdev-2.6 queue, and should be in the latest -mm.
> 
> 	Jeff
> 
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


I have a SysKonnect card, and tried the skge driver (it's in the mm tree), with nominal testing 
I'd have to say it works well, if not better then the sk98lin driver.



-- 
*--* Mail: lawrence@otak.com
*--* Voice: 425.739.4247
*--* Fax: 425.827.9577
*--* HTTP://the-penguin.otak.com/~lawrence
--------------------------------------
- - - - - - O t a k  i n c . - - - - - 
