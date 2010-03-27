From: David Miller <davem@davemloft.net>
Subject: Re: CVE-2009-4537
Date: Sat, 27 Mar 2010 10:36:00 -0700 (PDT)
Message-ID: <20100327.103600.246539458.davem@davemloft.net>
References: <20100327142100.38d21565.michael.s.gilbert@gmail.com>
	<20100327.103407.260084965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	nhorman@tuxdriver.com
To: michael.s.gilbert@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35519
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753701Ab0C0Rfg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 13:35:36 -0400
In-Reply-To: <20100327.103407.260084965.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Sat, 27 Mar 2010 10:34:07 -0700 (PDT)

> From: Michael Gilbert <michael.s.gilbert@gmail.com>
> Date: Sat, 27 Mar 2010 14:21:00 -0400
> 
>> Hi,
>> 
>> CVE-2009-4537 has been disclosed without any upstream activity for a
>> while now. Discussion about the issue dried up in January [0], and a
>> patch had been proposed [1], but no arguments were seen either for or
>> against it. Note that redhat has already shipped that in their various
>> kernel security updates.  Would it make sense to merge those changes
>> officially?
> 
> A different version of the fix went into the tree.

Ignore me, that was a fix for a different problem.

I was waiting for Francois to come up with a cleaner fix
but he stopped working on it, so yes I should put in
the fix you mention or something similar.

Neil, can you formally submit a version of the r8169
CVE for upstream?

Thanks.
