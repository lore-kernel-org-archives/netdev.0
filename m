From: Roland Dreier <rdreier@cisco.com>
Subject: Re: Hitting slab BUG with bridging/cxgb3 on 2.6.31-rc2
Date: Wed, 08 Jul 2009 17:12:11 -0700
Message-ID: <adatz1mzpd0.fsf@cisco.com>
References: <adaeisq23rq.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-6.cisco.com ([171.71.176.117]:5406 "EHLO
	sj-iport-6.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754795AbZGIAMN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 20:12:13 -0400
Received: from sj-core-2.cisco.com (sj-core-2.cisco.com [171.71.177.254])
	by sj-dkim-3.cisco.com (8.12.11/8.12.11) with ESMTP id n690CC2k018173
	for <netdev@vger.kernel.org>; Wed, 8 Jul 2009 17:12:12 -0700
Received: from xbh-sjc-231.amer.cisco.com (xbh-sjc-231.cisco.com [128.107.191.100])
	by sj-core-2.cisco.com (8.13.8/8.14.3) with ESMTP id n690CC3w012758
	for <netdev@vger.kernel.org>; Thu, 9 Jul 2009 00:12:12 GMT
In-Reply-To: <adaeisq23rq.fsf@cisco.com> (Roland Dreier's message of "Wed, 08
	Jul 2009 15:44:57 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FWIW, I hit this BUG with 2.6.31-rc1 too.  Testing 2.6.30 now.

 - R.
