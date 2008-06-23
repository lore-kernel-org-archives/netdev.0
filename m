From: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Subject: RE: [2.6 patch] remove CONFIG_NET_SCH_RR
Date: Mon, 23 Jun 2008 12:59:41 -0700
Message-ID: <D5C1322C3E673F459512FB59E0DDC329054E47C9@orsmsx414.amr.corp.intel.com>
References: <20080623174702.GD4756@cs181140183.pp.htv.fi> <D5C1322C3E673F459512FB59E0DDC3290549C885@orsmsx414.amr.corp.intel.com> <20080623194051.GA1885@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Patrick McHardy" <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"Robert P. J. Day" <rpjday@crashcourse.ca>
To: "Adrian Bunk" <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:39285 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754419AbYFWT7p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 15:59:45 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20080623194051.GA1885@cs181140183.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>But I doubt making these #ifdef's makes much sense.
>
>IMHO the best you can do is to add a note about RR to the NET_SCH_PRIO 
>help text.

Agreed.  I can generate a change to the help text to prio for it.

Thanks Adrian,

-PJ Waskiewicz
