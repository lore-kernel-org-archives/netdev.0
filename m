From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next v2] nlmon: use standard rtnetlink link api for
 add/del devices
Date: Tue, 02 Jul 2013 12:53:48 -0700 (PDT)
Message-ID: <20130702.125348.2038327019816849193.davem@davemloft.net>
References: <1372755331-1267-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dborkman@redhat.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53363 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754283Ab3GBTxt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 15:53:49 -0400
In-Reply-To: <1372755331-1267-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Tue,  2 Jul 2013 10:55:31 +0200

> It is not nice when netdev is created right after module load and with
> some implicit name. So rather change nlmon to use standard rtnl link API.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Applied, thanks Jiri.
