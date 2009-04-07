From: David Miller <davem@davemloft.net>
Subject: Re: [GIT]: Networking
Date: Mon, 06 Apr 2009 21:04:26 -0700 (PDT)
Message-ID: <20090406.210426.38766000.davem@davemloft.net>
References: <20090406.190745.263215778.davem@davemloft.net>
	<alpine.LFD.2.00.0904061931160.4010@localhost.localdomain>
	<20090406202441.1c050ec6@hobbes>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: jbarnes@virtuousgeek.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750722AbZDGEEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 00:04:37 -0400
In-Reply-To: <20090406202441.1c050ec6@hobbes>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Barnes <jbarnes@virtuousgeek.org>
Date: Mon, 6 Apr 2009 20:24:41 -0700

> On Mon, 6 Apr 2009 19:32:11 -0700 (PDT)
> Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
>> On Mon, 6 Apr 2009, David Miller wrote:
>> 
>> > From: Linus Torvalds <torvalds@linux-foundation.org>
>> > Date: Mon, 6 Apr 2009 18:25:31 -0700 (PDT)
>> > > 
>> > > 
>> > > The sky2 driver is buggered (by the previous pull, I presume).
>> > > Some PCI interaction. NULL pointer dereference at boot.
>> > 
>> > Fixed in the PCI tree, have you pulled that one yet?
>> 
>> Nobody has even _asked_ me to pull.
>> 
>> What's the point of having fixes available if they aren't merged?
> 
> I just pushed it into my repo today and wanted at least a day of
> linux-next before asking you to pull.

I feel like I've been watching people get pointed to that fix
for what seems like days.

In fact this is why I was under the impression that you had
already asked Linus to merge the fix. :-)

