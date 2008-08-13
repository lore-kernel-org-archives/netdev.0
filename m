From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/25] bnx2x: Bug Fixes
Date: Wed, 13 Aug 2008 16:06:51 -0700 (PDT)
Message-ID: <20080813.160651.193704999.davem@davemloft.net>
References: <1218636697.547.74.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yanivr@broadcom.com, gertner@broadcom.com,
	vladz@broadcom.com
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42514
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753647AbYHMXGu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 19:06:50 -0400
In-Reply-To: <1218636697.547.74.camel@lb-tlvb-eliezer>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Eilon Greenstein" <eilong@broadcom.com>
Date: Wed, 13 Aug 2008 17:11:37 +0300

> These patches contain bug fixes for the bnx2x driver. Please consider
> applying.

All applied, thanks Eilon.

But I had to undo some file permission changes that some of
these patches were making.  They were adding execute permission
to some of the source files.

You can see where this happens by looking for two line sequences of:

old mode ...
new mode ...

in the patches you posted.
