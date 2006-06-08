From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2.6.17-rc6-mm1 ] net: RFC 3828-compliant UDP-Lite
 support
Date: Thu, 08 Jun 2006 20:30:13 +0900 (JST)
Message-ID: <20060608.203013.61799645.yoshfuji@linux-ipv6.org>
References: <200606081150.34018@this-message-has-been-logged>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, kaber@coreworks.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:43536 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932270AbWFHL3b
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 07:29:31 -0400
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200606081150.34018@this-message-has-been-logged>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200606081150.34018@this-message-has-been-logged> (at Thu, 8 Jun 2006 11:50:33 +0100), Gerrit Renker <gerrit@erg.abdn.ac.uk> says:

> +  UDP-Lite introduces a new socket type, the SOCK_LDGRAM (note the L) for
> +  lightweight, connection-less services. These are the socket options:

I disagree.  It should be SOCK_DGRAM.

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
