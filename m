From: David Miller <davem@davemloft.net>
Subject: Re: [GIT PULL 0/5] IEEE 802.15.4 last-minute fixes.
Date: Tue, 04 Aug 2009 09:09:21 -0700 (PDT)
Message-ID: <20090804.090921.198630830.davem@davemloft.net>
References: <20090804085147.GA6724@doriath.ww600.siemens.net>
	<20090804.055810.201482741.davem@davemloft.net>
	<20090804144810.GA23722@doriath.ww600.siemens.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slapin@ossfans.org,
	linux-zigbee-devel@lists.sourceforge.net
To: dbaryshkov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37162
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751966AbZHDQJM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 12:09:12 -0400
In-Reply-To: <20090804144810.GA23722@doriath.ww600.siemens.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Date: Tue, 4 Aug 2009 18:48:10 +0400

> On Tue, Aug 04, 2009 at 05:58:10AM -0700, David Miller wrote:
>> From: Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
>> Date: Tue, 4 Aug 2009 12:51:48 +0400
>> 
>> > Will you pull the serie if I'll remove those two patches? Documentation
>> > fix isn't that important, however I'd really ask to pull the remaining
>> > two patches.
>> 
>> Yes.
> 
> Pushed the updated branch. Please pull.

Please don't resubmit changes like this.  It screws up all the
nice tracking of every patch we do on patchwork for networking
changes.

Please make a formal, full, reposting of the patch series you want me
to apply.  That way they can be tracked in patchwork, and the patches
can be replied to and commented upon (and such comments tracked in
patchwork as well).

When I say I'm tossing someone's changes, that means if they resubmit
they have to really resubmit everything, the patch postings at all.
Don't short-cut it with just a GIT tree refresh and pull request.

Thank you.
