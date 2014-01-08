From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 0/9] xen-netback: TX grant mapping with
 SKBTX_DEV_ZEROCOPY instead of copy
Date: Wed, 8 Jan 2014 14:43:24 +0000
Message-ID: <20140108144324.GA6984@zion.uk.xensource.com>
References: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53843 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756517AbaAHOnZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:43:25 -0500
Content-Disposition: inline
In-Reply-To: <1389139818-24458-1-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You once mentioned that you have a trick to avoid touching TLB, is it in
this series?

(Haven't really looked at this series as I'm in today. Will have a
closer look tonight. I'm just curious now.)

Wei.
