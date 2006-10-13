From: Daniel Drake <dsd@gentoo.org>
Subject: Re: [PATCH] sotftmac: fix a slab corruption in WEP restricted key
 association
Date: Fri, 13 Oct 2006 08:08:37 -0400
Message-ID: <452F81C5.9000801@gentoo.org>
References: <452D6D80.3020005@free.fr>  <452D8D83.60908@gentoo.org> <1160730291.2697.10.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Laurent Riffard <laurent.riffard@free.fr>, linville@tuxdriver.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.iad.emailsrvr.com ([207.97.245.111]:57808 "EHLO
	smtp111.iad.emailsrvr.com") by vger.kernel.org with ESMTP
	id S1751585AbWJMMJW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Oct 2006 08:09:22 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1160730291.2697.10.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Johannes Berg wrote:
> Good catch. We should send this to -stable too I think. Mind reposting
> the patch in an applicable format to Daniel, netdev, john, -stable (and
> possibly me)? Quoted isn't too useful :)

It was already sent to John directly. I was planning on sending it to 
-stable as soon as it hits Linus' tree.

Daniel

