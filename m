From: Thomas Scheiblauer <thomas.scheiblauer@hauptversammlung.at>
Subject: Re: [Bugme-new] [Bug 10380] New: sc92031 does not create a device
	link in sysfs
Date: Wed, 02 Apr 2008 19:08:40 +0200
Message-ID: <1207156120.8068.26.camel@tigershark.sharkbay.at>
References: <bug-10380-10286@http.bugzilla.kernel.org/>
	 <20080402091435.39f99428.akpm@linux-foundation.org>
	 <20080402094923.185f15dc@extreme>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org,
	Cesar Eduardo Barros <cesarb@cesarb.net>, tom@sharkbay.at
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15253013.onlinehome-server.info ([87.106.130.51]:35542 "EHLO
	hauptversammlung.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755573AbYDBRmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 13:42:54 -0400
In-Reply-To: <20080402094923.185f15dc@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mit, 2008-04-02 at 09:49 -0700, Stephen Hemminger wrote:
> Add missing sysfs device association. Compile tested only -ENOHW.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> ---
> Patch against 2.6.25-rc8, ignore previous patch.
> 
> ...

Works for me!
Thank you, that was fast.


