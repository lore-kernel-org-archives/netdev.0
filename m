From: jamal <hadi@cyberus.ca>
Subject: Re: [IFB]: Fix crash on input device removal
Date: Thu, 29 Mar 2007 12:52:15 -0400
Message-ID: <1175187135.4881.34.camel@localhost>
References: <460BE9B8.8030901@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.226]:32228 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030419AbXC2QwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 12:52:17 -0400
Received: by wr-out-0506.google.com with SMTP id 76so299786wra
        for <netdev@vger.kernel.org>; Thu, 29 Mar 2007 09:52:17 -0700 (PDT)
In-Reply-To: <460BE9B8.8030901@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2007-29-03 at 18:30 +0200, Patrick McHardy wrote:
> Fix the crash reported in the "another critical bug ?" thread,
> which turned out to be caused by a stale input_dev pointer.
> The patch applies to current -git and latest -stable.
> 

Mucho Gracias Patrick. Dont know if the ack is needed, but here it is.

Acked-by: Jamal Hadi Salim <hadi@cyberus.ca>

cheers,
jamal

