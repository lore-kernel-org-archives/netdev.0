From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP timewait recycle/reuse for IPv6?
Date: Mon, 17 Mar 2008 10:43:29 -0700
Message-ID: <47DEADC1.1040908@hp.com>
References: <200803171818.17494.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Octavian Purdila <opurdila@ixiacom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:22762 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751605AbYCQRnc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2008 13:43:32 -0400
In-Reply-To: <200803171818.17494.opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Octavian Purdila wrote:
> Hi,
> 
> Is there a way to prevent getting bind(in6addr_any) failures when we
> have lots of TIMEWAIT sockets hanging around? It looks like timewait
> reuse/recyle is not supported in the IPv6 stack.

What is the definition/value of "lots" here?

rick jones
