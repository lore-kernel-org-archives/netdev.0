From: "Dale Farnsworth" <dale@farnsworth.org>
Subject: Re: Bug report for MV643XX driver
Date: Wed, 9 Aug 2006 09:24:25 -0700
Message-ID: <20060809162425.GA7464@xyzzy.farnsworth.org>
References: <200608091047.28571.peloquin@mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dale@farnsworth.org, mlachwani@mvista.com, netdev@vger.kernel.org,
	josejx@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h142-az.mvista.com ([65.200.49.142]:10761 "HELO farnsworth.org")
	by vger.kernel.org with SMTP id S1750787AbWHIQY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 12:24:28 -0400
To: Stuart Peloquin <peloquin@MIT.EDU>
Content-Disposition: inline
In-Reply-To: <200608091047.28571.peloquin@mit.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 09, 2006 at 10:47:28AM -0400, Stuart Peloquin wrote:
> Kernel oops during heavy load downloads with the MV643XX driver on a PegII.  
> I've replicated the problem on 2.6.17_gentoo-4, vanilla 2.6.17.1, vanilla 
> 2.6.18_rc3.  When downloading a large file from any fast mirror (I tested 
> getting around 2.0MB/s) the system crashes after a random amount of time.  
> Usually after 30seconds to a couple of minutes.
> 
> I took pictures of the call trace, I'm sorry about the quality, they were 
> taken with a phone camera.  They can be viewed at 
> http://web.mit.edu/peloquin/marvell

Thanks for the report Stuart.  I'm investigating this now.  Would you
mind sending me the config file used to build the kernel?  Also, which
version of gcc are you using?

Thanks,
-Dale
