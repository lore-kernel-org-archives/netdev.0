From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net:mac80211:mesh_plink: remove redundant sta_info check
Date: Tue, 26 Jan 2016 14:10:28 +0100
Message-ID: <1453813828.2759.42.camel@sipsolutions.net>
References: <1453354585-26069-1-git-send-email-shshahu@gmail.com>
	 (sfid-20160121_063642_266180_2ACB780C)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sunil Shahu <shshahu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:39603 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933597AbcAZNKb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jan 2016 08:10:31 -0500
In-Reply-To: <1453354585-26069-1-git-send-email-shshahu@gmail.com> (sfid-20160121_063642_266180_2ACB780C)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-21 at 11:06 +0530, Sunil Shahu wrote:
> Remove unnecessory "if" statement and club it with previos "if"
> block.
> 
Applied.

johannes
