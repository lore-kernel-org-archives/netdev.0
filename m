From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Net watchdog triggering on r8169
Date: Fri, 20 Mar 2009 21:04:09 +0100
Message-ID: <200903202104.10000.mb@bu3sch.de>
References: <200902211625.55377.mb@bu3sch.de> <200903191835.14571.mb@bu3sch.de> <20090319222722.GB1972@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Rui Santos <rsantos@grupopie.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bu3sch.de ([62.75.166.246]:54247 "EHLO vs166246.vserver.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbZCTUFb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 16:05:31 -0400
In-Reply-To: <20090319222722.GB1972@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 March 2009 23:27:22 Francois Romieu wrote:
> Michael Buesch <mb@bu3sch.de> :
> [...]
> > Is this simply due to r8169 being cheap-ass hardware, or could this
> > be a real driver bug?
> 
> It could be a real driver bug / regression. Rui sent me enough information
> to code a patch. 

Can you post the patch when it's ready, so I can also test it?

Thanks a lot for your patience. :)

-- 
Greetings, Michael.
