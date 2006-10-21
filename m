From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] bcm43xx: Readd dropped assignment
Date: Fri, 20 Oct 2006 23:42:46 -0400
Message-ID: <45399736.1050709@gentoo.org>
References: <20061017231212.A73D77B40A0@zog.reactivated.net> <200610181640.01140.mb@bu3sch.de> <20061021032900.GB17706@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, linville@tuxdriver.com,
	Larry.Finger@lwfinger.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp151.iad.emailsrvr.com ([207.97.245.151]:16279 "EHLO
	smtp151.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1751107AbWJUDnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Oct 2006 23:43:40 -0400
To: Dave Jones <davej@redhat.com>
In-Reply-To: <20061021032900.GB17706@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> Is that one for -stable too? That file looks similar enough
> between .18.1 and .19rc that it should be the case ?

No. The IV/ICV stripping change was only merged into John's tree very 
recently (the day I sent the fix).

Daniel
