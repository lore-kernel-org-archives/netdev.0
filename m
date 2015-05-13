From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fix missing copy_from_user in macvtap
Date: Wed, 13 May 2015 14:21:49 -0400 (EDT)
Message-ID: <20150513.142149.1845378380922329394.davem@davemloft.net>
References: <1431516916.3278.8.camel@myriabit.com>
	<20150513.120956.970928701180963590.davem@davemloft.net>
	<1431541142.3278.10.camel@myriabit.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: justin@myriabit.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55813 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753446AbbEMSVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2015 14:21:51 -0400
In-Reply-To: <1431541142.3278.10.camel@myriabit.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Justin Cormack <justin@myriabit.com>
Date: Wed, 13 May 2015 19:19:02 +0100

> Fix missing copy_from_user in macvtap SIOCSIFHWADDR ioctl.
> 
> Signed-off-by: Justin Cormack <justin@netbsd.org>

Applied.
