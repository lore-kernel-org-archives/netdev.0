From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH 0/4] atl1: Attansic L1 ethernet driver
Date: Tue, 23 Jan 2007 10:42:04 -0600
Message-ID: <45B63ADC.8060808@bellsouth.net>
References: <20070121210416.GA2702@osprey.hogchain.net> <45B5A3D5.6020508@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, csnook@redhat.com, hch@infradead.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	atl1-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from imf21aec.mail.bellsouth.net ([205.152.59.69]:57357 "EHLO
	imf21aec.mail.bellsouth.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932941AbXAWQmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 11:42:08 -0500
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <45B5A3D5.6020508@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:

> OK, I have merged the monolithic patch into jgarzik/netdev-2.6.git#atl1. 
>  Once I'm done merging patches tonight, I will merge this new 'atl1' 
> branch into the 'ALL' meta-branch, which will auto-propagate this driver 
> into Andrew Morton's -mm for testing.
> 
> For future driver updates, please send a patch rather than the full 
> driver diff.

Perhaps a dumb question, but when can I begin submitting differential 
patches?  Now?  I'd like to incorporate some of Arjan's and Randy's 
comments.

Thank you very much for accepting the driver.

Jay
