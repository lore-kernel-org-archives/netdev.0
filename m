From: David Miller <davem@davemloft.net>
Subject: Re: Please queue commit 16c0b164bd24d44db for stable
Date: Wed, 21 May 2014 17:15:56 -0400 (EDT)
Message-ID: <20140521.171556.1536408784722270029.davem@davemloft.net>
References: <CAHA+R7OQrH9Ay0HRfLFNw4OBzhawqfT8gEW2j0nV5ntzey0p+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: cwang@twopensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56112 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751786AbaEUVP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 17:15:57 -0400
In-Reply-To: <CAHA+R7OQrH9Ay0HRfLFNw4OBzhawqfT8gEW2j0nV5ntzey0p+A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <cwang@twopensource.com>
Date: Mon, 19 May 2014 16:36:08 -0700

> Please queue the following commit for stable (for kernel < 3.6):
> 
> commit 16c0b164bd24d44db137693a36b428ba28970c62
> Author: Jason Wang <jasowang@redhat.com>
> Date:   Wed Aug 15 20:44:27 2012 +0000
> 
>     act_mirred: do not drop packets when fails to mirror it
> 
> 
> $ git describe --contains 16c0b164bd24d44db
> v3.6-rc3~10^2~23
> 
> It fixes some real bug.

Queued up, thanks.
