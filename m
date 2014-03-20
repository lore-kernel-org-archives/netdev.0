From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [PATCH net-next 1/2] af_ieee802154: fix check on broadcast
 address
Date: Thu, 20 Mar 2014 22:41:06 +0100
Message-ID: <20140320214105.GA1531@x61s.Speedport_W_921V_1_24_000>
References: <1395323823-20970-1-git-send-email-alex.aring@gmail.com>
 <20140320.172030.1849954665582219336.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	phoebe.buckheister@itwm.fraunhofer.de, jlu@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:37692 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760148AbaCTV2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 17:28:12 -0400
Received: by mail-ee0-f46.google.com with SMTP id t10so1137887eei.19
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 14:28:11 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20140320.172030.1849954665582219336.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Mar 20, 2014 at 05:20:30PM -0400, David Miller wrote:
> From: Alexander Aring <alex.aring@gmail.com>
> Date: Thu, 20 Mar 2014 14:57:02 +0100
> 
> > This patch fixes an issue which was introduced by commit
> > (b70ab2e87f17176d18f67ef331064441a032b5f3).
> 
> The canonical way to refer to commits is:
> 
> $SHA1_ID ("Commit message header line.")

ok, thanks. I will do it right next time. Sorry.

- Alex
