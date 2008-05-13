From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] [DCCP]: Deprecate SOCK_DCCP in favour of SOCK_DGRAM
Date: Tue, 13 May 2008 00:39:24 -0700 (PDT)
Message-ID: <20080513.003924.170616140.davem@davemloft.net>
References: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dccp@vger.kernel.org, acme@redhat.com
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49669
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753332AbYEMHj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 03:39:29 -0400
In-Reply-To: <20080513072853.GB4514@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 13 May 2008 08:28:53 +0100

> Is there support for this change or are there reasons to keep SOCK_DCCP?

You'll have to accept it forever since there have been several
kernel releases already with DCCP support added and there are
applications out there.
