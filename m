From: "Julian Shao Liu" <shaoliu@uiuc.edu>
Subject: RE: [RFC] TCP Illinois preliminary version
Date: Tue, 3 Apr 2007 15:20:22 -0500
Message-ID: <200704032020.l33KKN3g008322@expredir6.cites.uiuc.edu>
References: <20070402204458.5aa6c0c7@oldman>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <chaitanya_tk@tamu.edu>, <jgarrison@tamu.edu>,
	<srikant@ifp.uiuc.edu>, <tbasar@control.csl.uiuc.edu>,
	<jheffner@psc.edu>, <netdev@vger.kernel.org>
To: "'Stephen Hemminger'" <shemminger@linux-foundation.org>,
	"'David Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from expredir6.cites.uiuc.edu ([128.174.5.97]:62739 "EHLO
	expredir6.cites.uiuc.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945910AbXDCUbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2007 16:31:37 -0400
In-Reply-To: <20070402204458.5aa6c0c7@oldman>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Stephen, David 

Yes, you can go ahead to implement it in Linux. We are glad to see that
TCP-Illinois gets more exposure by this way.


Best regards!
 
Yours sincerely,
Shao Liu (Julian)
 
University of Illinois at Urbana Champaign
Coordinated Science Laboratory and Department of Electrical and Computer
Engineering
www.ews.uiuc.edu/~shaoliu

-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@linux-foundation.org] 
Sent: Monday, April 02, 2007 10:45 PM
To: David Miller
Cc: shaoliu@uiuc.edu; chaitanya_tk@tamu.edu; jgarrison@tamu.edu;
srikant@ifp.uiuc.edu; tbasar@control.csl.uiuc.edu; jheffner@psc.edu;
netdev@vger.kernel.org
Subject: Re: [RFC] TCP Illinois preliminary version

On Mon, 02 Apr 2007 20:39:37 -0700 (PDT) David Miller <davem@davemloft.net>
wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 2 Apr 2007 20:15:25 -0700
> 
> > Preliminary version if TCP Illinois for 2.6.22.
> > It needs more testing and refinement but it captures the basic 
> > concepts.
> 
> No objections from me and I don't see any obvious problems.
> 
> Would you like me to stuff this into net-2.6.22 now so that it can get 
> some more exposure and people banging on it or would you like me to 
> wait a bit?
> 
> Thanks.

I would like one of the originators to check the math. 

In case you are worried, I received assurance from Shao Liu that they
decided not to pursue patent and doing a Linux version was okay.

