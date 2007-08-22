From: David Miller <davem@davemloft.net>
Subject: Re: Oops in e100_up
Date: Wed, 22 Aug 2007 02:17:11 -0700 (PDT)
Message-ID: <20070822.021711.94557196.davem@davemloft.net>
References: <200708220956.48297@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48338
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761197AbXHVJRM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Aug 2007 05:17:12 -0400
In-Reply-To: <200708220956.48297@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Wed, 22 Aug 2007 09:56:48 +0100

> With the davem-2.6.24 tree I get the following Oops in the e100 driver (cribbed from console):

Probably the NAPI conversion, I'll try to get to diagnosing this
one soon but I've been wrapped up in some other tasks so if
someone could beat me to it that'd be great :-)
