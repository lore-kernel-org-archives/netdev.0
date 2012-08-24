From: "Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>
Subject: Re: [PATCH v2] net: add new QCA alx ethernet driver
Date: Fri, 24 Aug 2012 09:32:02 +0500
Message-ID: <CAB=NE6Xg=NUsb-hQyxr+-RyzpkJ-BH6RbbcTX6KF23H+u4yEPQ@mail.gmail.com>
References: <1345480949-14800-1-git-send-email-cjren@qca.qualcomm.com>
 <20120822.225700.714020017287504609.davem@davemloft.net> <157393863283F442885425D2C45428562A4F5169@nasanexd02f.na.qualcomm.com>
 <1345756142.2579.16.camel@bwh-desktop.uk.solarflarecom.com>
 <157393863283F442885425D2C45428562A4F54E3@nasanexd02f.na.qualcomm.com>
 <1345774184.2579.51.camel@bwh-desktop.uk.solarflarecom.com> <157393863283F442885425D2C45428562A4F5546@nasanexd02f.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"Ren, Cloud" <cjren@qca.qualcomm.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	qca-linux-team <qca-linux-team@qualcomm.com>,
	nic-devel <nic-devel@qualcomm.com>
To: "Huang, Xiong" <xiong@qca.qualcomm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:36474 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365Ab2HXEcY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 00:32:24 -0400
In-Reply-To: <157393863283F442885425D2C45428562A4F5546@nasanexd02f.na.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 24, 2012 at 6:39 AM, Huang, Xiong <xiong@qca.qualcomm.com> wrote:

It would be useful for you to keep the tag of who wrote what if you
are trimming the e-mails, like in the above you removed the option for
me to easily discover who wrote what.

>> If you want to implement a more sophisticated packet matching mode that
>> requires more details than struct ethtool_wolinfo, then you may need to
>> define new operations.
>>
> It's great !
> Is it ok for ethtool to define a new operation with a sophisticated structure (like ethtool_eee) ?

It would be useful for you to describe the exact functionality,
perhaps in a separate thread or maybe even just RFC patches which you
have to be simply ready for may just be just that -- RFC patches which
we flush down the v2 toilet.

  Luis
