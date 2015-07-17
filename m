From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net: wireless: reduce log level of CRDA related messages
Date: Fri, 17 Jul 2015 14:37:44 +0200
Message-ID: <1437136664.1933.10.camel@sipsolutions.net>
References: <1436448915-31724-1-git-send-email-thomas.petazzoni@free-electrons.com>
	 (sfid-20150709_153528_507259_B4073E38)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:52707 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757205AbbGQMhv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jul 2015 08:37:51 -0400
In-Reply-To: <1436448915-31724-1-git-send-email-thomas.petazzoni@free-electrons.com> (sfid-20150709_153528_507259_B4073E38)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-07-09 at 15:35 +0200, Thomas Petazzoni wrote:
> With a basic Linux userspace, the messages "Calling CRDA to update
> world regulatory domain" appears 10 times after boot every second or
> so, followed by a final "Exceeded CRDA call max attempts. Not calling
> CRDA". For those of us not having the corresponding userspace parts,
> having those messages repeatedly displayed at boot time is a bit
> annoying, so this commit reduces their log level to pr_debug().
> 
Applied.

johannes
