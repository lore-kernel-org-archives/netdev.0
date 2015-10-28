From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] mpls: mulipath improvements
Date: Tue, 27 Oct 2015 19:53:37 -0700 (PDT)
Message-ID: <20151027.195337.1069082631939252102.davem@davemloft.net>
References: <1445906256-14927-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	ebiederm@xmission.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44662 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755216AbbJ1Cgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 22:36:55 -0400
In-Reply-To: <1445906256-14927-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Tue, 27 Oct 2015 00:37:34 +0000

> Two improvements to the recently added mpls multipath support. The
> first is a fix for missing initialisation the nexthop address length
> for the v4 and v6 explicit null label routes, and the second is to
> reduce the amount of memory used by mpls routes by changing the way
> the via addresses are stored.

Series applied, thanks.
