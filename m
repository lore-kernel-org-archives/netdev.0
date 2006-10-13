From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] sotftmac: fix a slab corruption in WEP restricted key
	association
Date: Fri, 13 Oct 2006 14:12:45 +0200
Message-ID: <1160741565.2697.13.camel@ux156>
References: <452D6D80.3020005@free.fr>  <452D8D83.60908@gentoo.org>
	 <1160730291.2697.10.camel@ux156>  <452F81C5.9000801@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Laurent Riffard <laurent.riffard@free.fr>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:46805 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751639AbWJMML5
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 08:11:57 -0400
To: Daniel Drake <dsd@gentoo.org>
In-Reply-To: <452F81C5.9000801@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-10-13 at 08:08 -0400, Daniel Drake wrote:
> Johannes Berg wrote:
> > Good catch. We should send this to -stable too I think. Mind reposting
> > the patch in an applicable format to Daniel, netdev, john, -stable (and
> > possibly me)? Quoted isn't too useful :)
> 
> It was already sent to John directly. I was planning on sending it to 
> -stable as soon as it hits Linus' tree.

Oh ok, good. Thanks.

johannes
