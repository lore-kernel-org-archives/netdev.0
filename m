From: Pavel Roskin <proski@gnu.org>
Subject: Re: [PATCH] hostap_plx: fix CIS verification
Date: Tue, 24 Oct 2006 20:48:09 -0400
Message-ID: <1161737289.29298.6.camel@dv>
References: <1161382815.5803.2.camel@dv> <20061021011943.GC6140@jm.kir.nu>
	 <20061025003707.GB7340@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hostap@shmoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from c60.cesmail.net ([216.154.195.49]:37967 "EHLO c60.cesmail.net")
	by vger.kernel.org with ESMTP id S1161295AbWJYAsK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2006 20:48:10 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20061025003707.GB7340@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 20:37 -0400, John W. Linville wrote:
> Will you be refactoring this patch?  Or do you disagree with Jouni's
> assessment?

OK, give me an hour to produce a better patch.  My patch has an
advantage of being simple and of fixing exactly one thing, but if Jouni
feels more comfortable with an additional check, I'll add it.

I don't have Coverity to check, and I think the results of Coverity were
misinterpreted.  It doesn't know anything about CIS structure.  Anyway,
let me just check Jouni's suggestion on a real PLX card.

-- 
Regards,
Pavel Roskin

