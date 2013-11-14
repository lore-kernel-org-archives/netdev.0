From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC 0/7] genetlink: reduce ops size and complexity
Date: Thu, 14 Nov 2013 17:02:51 +0100
Message-ID: <1384444971.13941.37.camel@jlt4.sipsolutions.net>
References: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:49200 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752504Ab3KNQC6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 11:02:58 -0500
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:256)
	(Exim 4.80)
	(envelope-from <johannes@sipsolutions.net>)
	id 1VgzNe-00009L-AB
	for netdev@vger.kernel.org; Thu, 14 Nov 2013 17:02:54 +0100
In-Reply-To: <1384420486-8713-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-11-14 at 10:14 +0100, Johannes Berg wrote:
> This series of patches updates a few genetlink users and then
> makes the ops a static const array, reducing kernel size and
> code complexity.
> 
> Comments welcome.

Well, there were some major bugs in here, but now it seems to work. I'll
repost properly with everybody in CC.

johannes
