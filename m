From: David Miller <davem@davemloft.net>
Subject: Re: [DECNET] Endian bug fixes
Date: Tue, 07 Nov 2006 14:59:41 -0800 (PST)
Message-ID: <20061107.145941.79296060.davem@davemloft.net>
References: <1162809062.27980.311.camel@quoit.chygwyn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: patrick@tykepenguin.com, netdev@vger.kernel.org,
	viro@ftp.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:51178
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1753839AbWKGW7k (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Nov 2006 17:59:40 -0500
To: swhiteho@redhat.com
In-Reply-To: <1162809062.27980.311.camel@quoit.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Steven Whitehouse <swhiteho@redhat.com>
Date: Mon, 06 Nov 2006 10:31:02 +0000

> Hi,
> 
> Here is a patch which fixes some endianess problems. Patrick: since you
> have both big & little endian machines at your disposal, can you test to
> ensure this is ok? Thanks,

Applied, thanks Steven and Al.
