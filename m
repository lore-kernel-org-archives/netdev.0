From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [1/2] 2.6.22-rc4: known regressions with patches
Date: Tue, 05 Jun 2007 16:07:42 +0100
Message-ID: <1181056062.16089.17.camel@hades.cambridge.redhat.com>
References: <46657924.4010505@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, viro@zeniv.linux.org.uk,
	Uwe Bugla <uwe.bugla@gmx.de>, Ken Chen <kenchen@google.com>,
	Artem Bityutskiy <Artem.Bityutskiy@nokia.com>,
	Haavard Skinnemoen <hskinnemoen@atmel.com>,
	Christoph Lameter <clameter@sgi.com>,
	Dave Airlie <airlied@linux.ie>,
	Andrea Righi <righiandr@users.sourceforge.net>,
	Netdev <netdev@vger.kernel.org>,
	Strobl Anton <a.strobl@aws-it.at>,
	Patrick McHardy <kaber@trash.net>
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:56230 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbXFEPHt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 11:07:49 -0400
In-Reply-To: <46657924.4010505@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2007-06-05 at 16:54 +0200, Michal Piotrowski wrote:
> File systems
> 
> Subject    : JFFS2 issues
> References : http://lists.infradead.org/pipermail/linux-mtd/2007-May/018426.html
> Submitter  : Haavard Skinnemoen <hskinnemoen@atmel.com>
> Caused-By  : commit 10731f83009e2556f98ffa5c7c2cbffe66dacfb3
>              Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
> Handled-By : Artem Bityutskiy <Artem.Bityutskiy@nokia.com>
> Patch      : http://lists.infradead.org/pipermail/linux-mtd/2007-May/018453.html
> Status     : patch available
> 

This is fixed in 2.6.22-rc4 with this commit:
http://git.kernel.org/git/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=ea55d30798ac206c9f584ac264b6b8eb093d237a

-- 
dwmw2

