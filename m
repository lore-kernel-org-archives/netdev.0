From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH for 2.6.31] cxgb3: Fix crash caused by stashing wrong netdev_queue
Date: Thu, 09 Jul 2009 16:16:19 -0700
Message-ID: <ada3a95xxa4.fsf@cisco.com>
References: <adaeisq23rq.fsf@cisco.com> <adaljmyzof4.fsf@cisco.com>
	<4A554A1D.3070703@chelsio.com> <adabpnty7qm.fsf_-_@cisco.com>
	<4A565DE9.3040504@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:21218 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750809AbZGIXQU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 19:16:20 -0400
In-Reply-To: <4A565DE9.3040504@chelsio.com> (Divy Le Ray's message of "Thu, 09
	Jul 2009 14:15:21 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


 > You were very fast to fix it, you beat us.

motivated -- I wanted to be able to use the system where I saw the crash :)
