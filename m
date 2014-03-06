From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] be2net: do external loopback test only
 when it is requested
Date: Thu, 06 Mar 2014 17:01:31 -0500 (EST)
Message-ID: <20140306.170131.1304677099455368338.davem@davemloft.net>
References: <1394016845-5376-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com,
	sergei.shtylyov@cogentembedded.com
To: ivecera@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33912 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751087AbaCFWBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2014 17:01:33 -0500
In-Reply-To: <1394016845-5376-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ivan Vecera <ivecera@redhat.com>
Date: Wed,  5 Mar 2014 11:54:05 +0100

> v2: remove unnecessary braces from all 'loopback' if-blocks (thx Sergei)
> 
> Cc: sathya.perla@emulex.com
> Cc: subbu.seetharaman@emulex.com
> Cc: ajit.khaparde@emulex.com
> Cc: sergei.shtylyov@cogentembedded.com
> 
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>

Applied, thank you.
