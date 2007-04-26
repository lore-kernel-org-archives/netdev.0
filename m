From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TIPC]: Changed msg_set_bits params type
Date: Thu, 26 Apr 2007 14:45:21 -0700 (PDT)
Message-ID: <20070426.144521.98863152.davem@davemloft.net>
References: <46310443.7090405@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	jon.maloy@donjonn.com, per.liden@ericsson.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39387
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755283AbXDZVpO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 17:45:14 -0400
In-Reply-To: <46310443.7090405@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jon Paul Maloy <jon.maloy@ericsson.com>
Date: Thu, 26 Apr 2007 15:57:55 -0400

> To ease use of sparse, as requested by Ingo Oeser.
> 
> Signed-off-by: Jon Paul Maloy <jon.maloy@ericsson.com>

Did you actually run sparse to see what warnings this change
adds or deletes or are you submitting untested changes?
