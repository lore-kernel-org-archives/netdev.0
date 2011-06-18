From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH v2 1/5] net:  Support ethtool ops for rx of errored frames.
Date: Sat, 18 Jun 2011 23:34:00 +0200
Message-ID: <20110618213400.GA2741@electric-eye.fr.zoreil.com>
References: <1308430045-24816-1-git-send-email-greearb@candelatech.com> <1308430045-24816-2-git-send-email-greearb@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: greearb@candelatech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49965 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741Ab1FRVqn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2011 17:46:43 -0400
Content-Disposition: inline
In-Reply-To: <1308430045-24816-2-git-send-email-greearb@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

greearb@candelatech.com <greearb@candelatech.com> :
[...]
> This can be useful when sniffing dodgy networks.

Do you plan to add something similar - i.e. not per packet - for the Tx path ?

-- 
Ueimor
