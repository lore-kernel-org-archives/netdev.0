From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: Fix for ipv6_setsockopt NULL dereference
Date: Fri, 09 Mar 2007 23:40:25 +0900 (JST)
Message-ID: <20070309.234025.129517839.yoshfuji@linux-ipv6.org>
References: <200703091207.31877.olaf.kirch@oracle.com>
	<200703091515.55985.olaf.kirch@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: olaf.kirch@oracle.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:34537 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767324AbXCIOj7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 09:39:59 -0500
In-Reply-To: <200703091515.55985.olaf.kirch@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200703091515.55985.olaf.kirch@oracle.com> (at Fri, 9 Mar 2007 15:15:54 +0100), Olaf Kirch <olaf.kirch@oracle.com> says:

> I came across this bug in http://bugzilla.kernel.org/show_bug.cgi?id=8155
:
> Fix NULL pointer derefence in ipv6_setsockopt, as described in bug #8155.
> 
> Signed-off-by: olaf.kirch@oracle.com

Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

I also ack to push this to -stable.

--yoshfuji
