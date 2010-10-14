From: Jon Maloy <jon.maloy@ericsson.com>
Subject: RE: [PATCH net-next] tipc: cleanup function namespace
Date: Thu, 14 Oct 2010 15:49:52 -0400
Message-ID: <0434463FDA60A94FA978ACA44617682DEE845A60EE@EUSAACMS0702.eamcs.ericsson.se>
References: <1286929558-2954-5-git-send-email-paul.gortmaker@windriver.com>
	<20101013162652.GF31379@hmsreliant.think-freely.org>
	<4CB5E79B.4060507@windriver.com>
	<20101013.142834.226768662.davem@davemloft.net>
	<20101013162035.0c2e8123@nehalam>	<4CB64D7C.1080004@windriver.com>
	<20101014012951.GA2186@localhost.localdomain>
	<4CB74391.9020400@windriver.com> <20101014113320.7720828f@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"allan.stephens@windriver.com" <allan.stephens@windriver.com>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.8]:37837 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755262Ab0JNTuK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 15:50:10 -0400
In-Reply-To: <20101014113320.7720828f@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


<...> 
> > justify a technically wrong decision here on netdev anyway.
> > 
> > I was just describing the history of the situation, and 
> suggesting one 
> > possible slower approach of phasing it out as a courtesy to those 
> > users, in the same way that the kernel community has extended that 
> > same courtesy with other things in feature-removal.txt
> > 
> > In the end, since Jon is OK with the removal, and is in the 
> process of 
> > communicating this to the API users he is aware of, I sure 
> don't have 
> > any reason to try and save the API.  If folks are good with 
> having it 
> > just go away overnight, then great -- I'll be just as happy 
> to see it 
> > disappear as you and Stephen.  So, a long winded way of saying...
> > 
> > Acked-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> 
> How about putting an entry in feature-removal.txt with a 
> short (6 month) window?

I think that is a very good idea. That would give the users a reasonable time
to find other solutions.

> 
> 
> --
> --
> To unsubscribe from this list: send the line "unsubscribe 
> netdev" in the body of a message to majordomo@vger.kernel.org 
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 