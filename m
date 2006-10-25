From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: e100: Wait for PHY reset to complete?
Date: Wed, 25 Oct 2006 20:56:56 +0200
Message-ID: <20061025185656.GA19037@electric-eye.fr.zoreil.com>
References: <453F9D4A.8090306@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:36788 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1030199AbWJYS7g
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 14:59:36 -0400
To: Anders Grafstrom <grfstrm@users.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <453F9D4A.8090306@users.sourceforge.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Anders Grafstrom <grfstrm@users.sourceforge.net> :
[...]
> I'm thinking something like this patch.

I do not have the spec for the max duration at hand but it makes sense.

Can you:
- decrease the duration of each sleep and increase the count of iterations
- put the break on a line of its own
- add a Signed-off-by: Foo Bar <baz@nit.fol> line
- Cc: jeff@garzik.org and Auke Kok <auke-jan.h.kok@intel.com>

-- 
Ueimor
