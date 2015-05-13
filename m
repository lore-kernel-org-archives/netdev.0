From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] macvtap add missing ioctls
Date: Wed, 13 May 2015 12:09:56 -0400 (EDT)
Message-ID: <20150513.120956.970928701180963590.davem@davemloft.net>
References: <1431370810.3278.4.camel@myriabit.com>
	<20150512.230121.330638562727327262.davem@davemloft.net>
	<1431516916.3278.8.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: justin@myriabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54680 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752299AbbEMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 12:09:59 -0400
In-Reply-To: <1431516916.3278.8.camel@myriabit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Cormack <justin@myriabit.com>
Date: Wed, 13 May 2015 12:35:16 +0100

> The macvtap driver tries to emulate all the ioctls supported by a normal
> tun/tap driver, however it was missing the generic SIOCGIFHWADDR and
> SIOCSIFHWADDR ioctls to get and set the mac address that are supported
> by tun/tap. This patch adds these.
> 
> Signed-off-by: Justin Cormack <justin@netbsd.org>

As I stated, you cannot just send a new version of a patch I already
applied to my tree.

It is in the permanent GIT commit record, and cannot be removed.

Therefore, you must send a relative fix.
