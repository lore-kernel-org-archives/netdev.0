From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2] netpoll: warn when there are spaces in parameters
Date: Mon, 22 Mar 2010 20:06:47 -0700 (PDT)
Message-ID: <20100322.200647.163253192.davem@davemloft.net>
References: <20100322090341.5289.10770.sendpatchset@localhost.localdomain>
	<20100322123046.GA4288@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, elendil@planet.nl
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315Ab0CWDGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Mar 2010 23:06:24 -0400
In-Reply-To: <20100322123046.GA4288@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Mon, 22 Mar 2010 08:30:46 -0400

> On Mon, Mar 22, 2010 at 04:59:58AM -0400, Amerigo Wang wrote:
>> v2: update according to Frans' comments.
>> 
>> Currently, if we leave spaces before dst port,
>> netconsole will silently accept it as 0. Warn about this.
>> 
>> Also, when spaces appear in other places, make them
>> visible in error messages.
>> 
>> Signed-off-by: WANG Cong <amwang@redhat.com>
 ...
> Acked-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks!
