From: David Miller <davem@davemloft.net>
Subject: Re: Fix for ipv6_setsockopt NULL dereference
Date: Fri, 09 Mar 2007 13:56:17 -0800 (PST)
Message-ID: <20070309.135617.35467797.davem@davemloft.net>
References: <200703091207.31877.olaf.kirch@oracle.com>
	<200703091515.55985.olaf.kirch@oracle.com>
	<20070309.234025.129517839.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: olaf.kirch@oracle.com, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38484
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S2993150AbXCIV4S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 16:56:18 -0500
In-Reply-To: <20070309.234025.129517839.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Fri, 09 Mar 2007 23:40:25 +0900 (JST)

> In article <200703091515.55985.olaf.kirch@oracle.com> (at Fri, 9 Mar 2007 15:15:54 +0100), Olaf Kirch <olaf.kirch@oracle.com> says:
> 
> > I came across this bug in http://bugzilla.kernel.org/show_bug.cgi?id=8155
> :
> > Fix NULL pointer derefence in ipv6_setsockopt, as described in bug #8155.
> > 
> > Signed-off-by: olaf.kirch@oracle.com
> 
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> I also ack to push this to -stable.

Thank you for reviewing.
