From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Pull request for 'upstream' branch
Date: Thu, 22 Jun 2006 23:34:28 -0400
Message-ID: <449B6144.5060800@garzik.org>
References: <20060622232048.GA9790@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roy Marples <uberlord@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:56199 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932075AbWFWDeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 23:34:31 -0400
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20060622232048.GA9790@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Please pull from branch 'upstream' to get the change below:
> 
> git://electric-eye.fr.zoreil.com/home/romieu/linux-2.6.git
> 
> Patch applies to jeff#upstream, jeff#upstream-fixes and jeff#upstream-linus.

Pulled.

FWIW, netdev#upstream-linus should almost always be ignored, and 
netdev#upstream-fixes is only valid during a -rc cycle.  Until 
2.6.18-rc1 is released, everything goes into netdev#upstream.

	Jeff



