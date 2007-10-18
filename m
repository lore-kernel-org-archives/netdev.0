From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pfkey: sending an SADB_GET responds with an SADB_GET
Date: Wed, 17 Oct 2007 19:29:06 -0700 (PDT)
Message-ID: <20071017.192906.112623207.davem@davemloft.net>
References: <C33BCE5A.25D04%chardin@2wire.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: chardin@2wire.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59580
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759154AbXJRC3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:29:07 -0400
In-Reply-To: <C33BCE5A.25D04%chardin@2wire.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Charles Hardin <chardin@2wire.com>
Date: Wed, 17 Oct 2007 14:36:10 -0700

> Kernel needs to respond to an SADB_GET with the same message type to conform
> to the RFC 2367 Section 3.1.5

I can't apply this:

1) We need you to provide an appropriate Signed-off-by: line
   in the changelog of your patch.

2) Your email client corrupted the patch, changing tabs into spaces,
   and adding newline breaks to long lines.

Please resubmit with these two errors corrected, thank you.
