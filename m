From: Michael Guntsche <mike@it-loops.com>
Subject: Re: [BUG] 2.6.33-rc1 gianfar error message
Date: Tue, 22 Dec 2009 12:52:45 +0100
Message-ID: <20091222115245.GA26930@gibson.comsick.at>
References: <20091220214447.GA10233@trillian.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F3B@zin33exm22.fsl.freescale.net>
 <20091221072704.GA12110@gibson.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08F83@zin33exm22.fsl.freescale.net>
 <20091221163843.GB3529@gibson.comsick.at>
 <9F4C7D19E8361D4C94921B95BE08B81BA08FCA@zin33exm22.fsl.freescale.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Kumar Gopalpet-B05799 <B05799@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:44831
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751468AbZLVLw6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Dec 2009 06:52:58 -0500
Content-Disposition: inline
In-Reply-To: <9F4C7D19E8361D4C94921B95BE08B81BA08FCA@zin33exm22.fsl.freescale.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22 Dec 09 10:32, Kumar Gopalpet-B05799 wrote:
> >Just for my understanding. Is the first diff part of the fix as well?
> >With this change the FCB is only removed if there are padded bytes, why
> >would this make a difference here?
> >
> 
> Yes, the first diff portion is not required.
> 
> Also, if you confirm that the changes are working fine.
> I will generate a clean patch and send it out.
> Thanks for reporting it and testing it out.

Hi,

I have now an uptime of 20 hours with no error messages so far. I had
one ppp disconnect but I think this was ADSL related. 

I will continue running this kernel for now to test it some more but I
think the initial problem I was seeing is fixed now.

Kind regards,
Michael

