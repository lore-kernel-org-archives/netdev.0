From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: optimize ctrl_dumpfamily()
Date: Wed, 13 Jan 2010 20:40:43 -0800 (PST)
Message-ID: <20100113.204043.259970060.davem@davemloft.net>
References: <m2bph5kodr.fsf@ssh.synack.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, johannes@sipsolutions.net, hadi@cyberus.ca,
	netdev@vger.kernel.org
To: sam@synack.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43020
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754795Ab0ANEke (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jan 2010 23:40:34 -0500
In-Reply-To: <m2bph5kodr.fsf@ssh.synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samir Bellabes <sam@synack.fr>
Date: Fri, 08 Jan 2010 09:10:56 +0100

>     there is a unnecessary test which can be replaced by a good initialization in
>     the 'for' statement
>     
>     Noticed by Serge E. Hallyn <serue@us.ibm.com>
>     
>     Signed-off-by: Samir Bellabes <sam@synack.fr>

Applied, thanks.
