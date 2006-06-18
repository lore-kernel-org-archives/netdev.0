From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: enable shared key authentication
Date: Sun, 18 Jun 2006 11:31:19 +0200
Message-ID: <200606181131.20188.mb@bu3sch.de>
References: <20060616195022.E73CD8A3591@zog.reactivated.net> <1150599685.2519.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Daniel Drake <dsd@gentoo.org>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:18090
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S1750743AbWFRJcN
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jun 2006 05:32:13 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1150599685.2519.7.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 18 June 2006 05:01, Dan Williams wrote:
> On Fri, 2006-06-16 at 20:50 +0100, Daniel Drake wrote:
> > I recently patched softmac to enable shared key authentication. This small patch
> > will enable crazy or unfortunate bcm43xx users to use this new capability.
> 
> Meaning that _until now_, softmac couldn't do Shared Key auth???
Yep.

-- 
Greetings Michael.
