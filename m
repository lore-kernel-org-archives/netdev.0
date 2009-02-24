From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 2.6.29-rc6: Reported regressions 2.6.27 -> 2.6.28
Date: Wed, 25 Feb 2009 00:23:23 +0100
Message-ID: <20090224232322.GA15079@electric-eye.fr.zoreil.com>
References: <HFSEX4uppGO.A.JSG.2yzoJB@chimera> <200902241705.33271.eike-kernel@sf-tec.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Network Development <netdev@vger.kernel.org>
To: Rolf Eike Beer <eike-kernel@sf-tec.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:49162 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753656AbZBXXVH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 18:21:07 -0500
Content-Disposition: inline
In-Reply-To: <200902241705.33271.eike-kernel@sf-tec.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rolf Eike Beer <eike-kernel@sf-tec.de> :
[...]
> would you agree to mark both as dupe of #10109?

I am not too hot. #10109 happens with a 8167.

We can probably mark as dupe the watchdog timeouts which happen on 
the same hardware (XID) at boot time though.

-- 
Ueimor
