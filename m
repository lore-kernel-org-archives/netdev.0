From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH 2/7] cxgb3 - private ioctl cleanup
Date: Thu, 22 Feb 2007 21:39:15 +0900 (JST)
Message-ID: <20070222.213915.89824941.yoshfuji@linux-ipv6.org>
References: <20070222115925.10001.61276.stgit@localhost.localdomain>
	<20070222.210618.134161490.yoshfuji@linux-ipv6.org>
	<45DD8DDA.8060303@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, swise@opengridcomputing.com,
	yoshfuji@linux-ipv6.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:57096 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933065AbXBVMjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Feb 2007 07:39:07 -0500
In-Reply-To: <45DD8DDA.8060303@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <45DD8DDA.8060303@chelsio.com> (at Thu, 22 Feb 2007 04:34:34 -0800), Divy Le Ray <divy@chelsio.com> says:


> > 1. Please do do change the values.
> > 2. Explain why you are going to kill these ioctls.
> >   
> Jeff and Arjan have required that most of these ioctls go.
> Please read:
> http://marc.theaimsgroup.com/?l=linux-netdev&m=117029584904193&w=2

Even if you remove them, PLEASE DO NOT CHANGE THE VALUES,
unless you have very, very good reason.

--yoshfuji
