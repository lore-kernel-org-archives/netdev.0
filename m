From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [patch] use socklen_t in iputils rather than just int
Date: Thu, 21 Dec 2006 00:12:42 +0900 (JST)
Message-ID: <20061221.001242.07124353.yoshfuji@linux-ipv6.org>
References: <200612201000.32723.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:41174 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965124AbWLTPMK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Dec 2006 10:12:10 -0500
To: vapier@gentoo.org
In-Reply-To: <200612201000.32723.vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <200612201000.32723.vapier@gentoo.org> (at Wed, 20 Dec 2006 10:00:32 -0500), Mike Frysinger <vapier@gentoo.org> says:

> a bunch of places in iputils utilize "int" lengths when in reality they should 
> be using socklen_t

Patch applied.  Thanks.

Please add some prefix in subject, please;
e.g. Subject: [IPUTILS] Use socklen_t in all the right places.

Regards,

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
