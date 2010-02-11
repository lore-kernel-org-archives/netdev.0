From: Dan Smith <danms@us.ibm.com>
Subject: Re: [PATCH 2/4] C/R: Basic support for network namespaces and	devices (v3)
Date: Thu, 11 Feb 2010 07:59:43 -0800
Message-ID: <873a17226o.fsf@caffeine.danplanet.com>
References: <1265750713-15749-1-git-send-email-danms@us.ibm.com>
	<1265750713-15749-3-git-send-email-danms@us.ibm.com>
	<87ljf1gemh.fsf@caffeine.danplanet.com>
	<20100211110234.GA14481@hawkmoon.kerlabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: containers@lists.osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw0.danplanet.com ([71.245.107.82]:54242 "EHLO
	mail.danplanet.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754852Ab0BKP7s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 10:59:48 -0500
In-Reply-To: <20100211110234.GA14481@hawkmoon.kerlabs.com> (Louis Rilling's message of "Thu\, 11 Feb 2010 12\:02\:35 +0100")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LR> I'm definitely not a network expert, but this kfree(skb) should probably be
LR> replaced by kfree_skb(skb).

Eesh, yep.  Thanks :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms@us.ibm.com
