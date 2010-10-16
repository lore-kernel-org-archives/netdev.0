From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: make single bit signed bitfields unsigned
Date: Sat, 16 Oct 2010 11:55:11 -0700 (PDT)
Message-ID: <20101016.115511.189718277.davem@davemloft.net>
References: <1286956346-17147-1-git-send-email-harvey.harrison@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: harvey.harrison@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54710
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753679Ab0JPSys (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Oct 2010 14:54:48 -0400
In-Reply-To: <1286956346-17147-1-git-send-email-harvey.harrison@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harvey Harrison <harvey.harrison@gmail.com>
Date: Wed, 13 Oct 2010 00:52:26 -0700

> Single bit signed bitfields don't make a lot of sense, noticed by sparse:
 ...
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>

Applied.
