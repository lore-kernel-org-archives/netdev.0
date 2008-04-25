From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/2] korina: fix misplaced return statement
Date: Fri, 25 Apr 2008 02:02:16 -0400
Message-ID: <481173E8.8060600@garzik.org>
References: <20080420160531.GA26599@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <florian.fainelli@telecomint.eu>,
	netdev@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58485 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757704AbYDYGCT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:02:19 -0400
In-Reply-To: <20080420160531.GA26599@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu wrote:
> The driver takes the error unwind path without condition.
> 
> Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

applied 1-2


