From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 802.1D/Linux STP issue
Date: Fri, 15 Sep 2006 09:15:28 +0900
Message-ID: <20060915091528.7b5912e9@localhost.localdomain>
References: <OF1AE42FF9.06C5D926-ON852571E7.005804CC-852571E7.0057EE7E@ieee.org>
	<45076B88.80104@bristyle.com>
	<6.0.1.1.2.20060913075410.04133280@mail.expressoweb.co.uk>
	<45088D29.30501@bristyle.com>
	<20060914100619.76cb1828@localhost.localdomain>
	<6.0.1.1.2.20060914174624.05055480@mail.expressoweb.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Brian Braunstein <brian@bristyle.com>,
	Rajesh Mishra <rajesh_mish@yahoo.com>, bridge@osdl.org,
	netdev@vger.kernel.org, mick_seaman@ieee.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:33946 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932165AbWIOAPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2006 20:15:44 -0400
To: Tony Jeffree <tony@jeffree.co.uk>
In-Reply-To: <6.0.1.1.2.20060914174624.05055480@mail.expressoweb.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 14 Sep 2006 17:51:50 +0100
Tony Jeffree <tony@jeffree.co.uk> wrote:

> Steve/Brian -
> 
> You've probably seen Mick Seaman's comments on this by now - as he points 
> out in his email, tinkering with existing STP implementations is not likely 
> to be a rewarding exercise and I would encourage you not to go there.
> 
> I would suggest that it would be a much more valuable exercise for the 
> Linux community to replace the existing STP support with an implementation 
> of RSTP.
> 
> Regards,
> Tony

Work is already in progress to do RSTP (by several different people),
but the effort is going slowly.
