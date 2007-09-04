From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH -mm 2/2] 3c59x MAINTAINERS
Date: Tue, 4 Sep 2007 09:55:40 +0200
Message-ID: <20070904075540.GA4241@newton.mathematik.tu-chemnitz.de>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in> <alpine.LFD.0.999.0709040351310.8504@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>
To: Satyam Sharma <satyam@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:57466 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbXIDHzn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 03:55:43 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709040351310.8504@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 04, 2007 at 03:52:50AM +0530, Satyam Sharma wrote:
> Remove duplicate entry for the same driver.

This is -mm specific. Andrew did not remove the add-3c59x-maintainer
patch after pushing it to mainline. This can be fixed just by removing
the add-3c59x-maintainer patch from -mm. 

