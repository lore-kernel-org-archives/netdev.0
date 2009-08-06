From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] documentation: fix wrt. headers rename
Date: Thu, 06 Aug 2009 10:34:48 -0700 (PDT)
Message-ID: <20090806.103448.34075186.davem@davemloft.net>
References: <1249457297-8355-4-git-send-email-dbaryshkov@gmail.com>
	<20090805.202226.24204308.davem@davemloft.net>
	<20090806092617.GA9209@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57235
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755602AbZHFRej (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 13:34:39 -0400
In-Reply-To: <20090806092617.GA9209@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Thu, 6 Aug 2009 13:26:17 +0400

> BTW: how should I differentiate my poll requests for net-next-2.6 and
> for net-2.6 ?

Like the rest of the world by indicating the target tree in your
subject lines.  As long as it's in those initial [] brackets,
the automated GIT tools strip it all out when applying patches.

Don't you see other patch posters putting things like "[NEXT ...]" and
"[net-2.6 ...]" and "[net-next-2.6 ...]" in their subjects?
