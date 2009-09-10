From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/12] Gigaset driver patches for 2.6.32
Date: Wed, 09 Sep 2009 20:51:51 -0700 (PDT)
Message-ID: <20090909.205151.123091735.davem@davemloft.net>
References: <20090909223205.E9D632269516@fifo99.com>
	<1252554477.30578.167.camel@desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tilman@imap.cc, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	hjlipp@web.de
To: dwalker@fifo99.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56357
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752091AbZIJDve (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2009 23:51:34 -0400
In-Reply-To: <1252554477.30578.167.camel@desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@fifo99.com>
Date: Wed, 09 Sep 2009 20:47:57 -0700

> On Thu, 2009-09-10 at 00:32 +0200, Tilman Schmidt wrote:
>> Daniel Walker wrote 07.09.09 16:30:
>> > Yeah, it looks like the whole file needs a checkpatch clean up..
>> Sounds
>> like your not willing to do that?
>> 
>> It's not a question of willingness. You may notice I did a lot of
>> cleanup work already. But it's very time consuming work, and there has
>> been more important work to attend to first.
>> 
>> > Usually if a checkpatch cleanup comes
>> first prior to all your other changes , it doesn't usually cloud the
>> rest of the changes..
>> 
>> Sure. But that would mean postponing the merging of bugfixes until
>> someone finds the time to do a complete checkpatch cleanup of the
>> affected code. I don't think that's a sensible approach.
> 
> You shouldn't be adding any new checkpatch errors, but you currently
> are .. Just clean up the individual patches w/o the entire gigaset
> driver, that should be do-able (it's even a basic submission
> requirement). The other issue is that your adding new files which aren't
> clean, those can certainly be cleaned up.

Right, this is a very reasonable request.
