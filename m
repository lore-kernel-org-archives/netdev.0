From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Net watchdog triggering on r8169
Date: Thu, 19 Mar 2009 23:27:22 +0100
Message-ID: <20090319222722.GB1972@electric-eye.fr.zoreil.com>
References: <200902211625.55377.mb@bu3sch.de> <200903191835.14571.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Rui Santos <rsantos@grupopie.com>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:52329 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760159AbZCTUBb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 16:01:31 -0400
Content-Disposition: inline
In-Reply-To: <200903191835.14571.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Buesch <mb@bu3sch.de> :
[...]
> Is this simply due to r8169 being cheap-ass hardware, or could this
> be a real driver bug?

It could be a real driver bug / regression. Rui sent me enough information
to code a patch. 

-- 
Ueimor
