From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v3 00/28] bonding/team offload + mlxsw
 implementation
Date: Thu, 3 Dec 2015 17:54:20 +0100
Message-ID: <20151203165420.GL2331@nanopsycho.orion>
References: <1449141150-8172-1-git-send-email-jiri@resnulli.us>
 <20151203.115140.1992432368275148930.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37435 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418AbbLCQyX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2015 11:54:23 -0500
Received: by wmww144 with SMTP id w144so30573889wmw.0
        for <netdev@vger.kernel.org>; Thu, 03 Dec 2015 08:54:22 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20151203.115140.1992432368275148930.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Dec 03, 2015 at 05:51:40PM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jiri@resnulli.us>
>Date: Thu,  3 Dec 2015 12:12:02 +0100
>
>> This patchset introduces needed infrastructure for link aggregation
>> offload - for both team and bonding. It also implements the offload
>> in mlxsw driver.
>
>Series applied, please send followups that do the const'ing Eric Dumazet
>asked for.

Will do. Thanks.
