From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Subject: Re: [PATCH 2/2] tc35815: Enable NAPI
Date: Thu, 29 Oct 2009 13:14:47 +0900 (JST)
Message-ID: <20091029.131447.138200535.anemo@mba.ocn.ne.jp>
References: <1256564782-2781-2-git-send-email-anemo@mba.ocn.ne.jp>
	<20091028.035743.76929614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mba.ocn.ne.jp ([122.28.14.163]:56943 "EHLO smtp.mba.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750761AbZJ2EOo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2009 00:14:44 -0400
In-Reply-To: <20091028.035743.76929614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 28 Oct 2009 03:57:43 -0700 (PDT), David Miller <davem@davemloft.net> wrote:
> Please remove the NAPI enabling macro and the tests for it.
> NAPI support should be unconditional.
> 
> If people want to test the pre-NAPI behavior, they can check
> out an older copy of the driver quite easily.

OK, I will do it.  Thank you.

---
Atsushi Nemoto
