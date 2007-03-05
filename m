From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][UDP]: Fix "whitespace" cleanup
Date: Sun, 04 Mar 2007 20:15:49 -0800 (PST)
Message-ID: <20070304.201549.71109671.davem@davemloft.net>
References: <39e6f6c70703041911u446bb4a0q324d5087237a57a7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, netdev@vger.kernel.org
To: acme@ghostprotocols.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47390
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752634AbXCEEPu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2007 23:15:50 -0500
In-Reply-To: <39e6f6c70703041911u446bb4a0q324d5087237a57a7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Mon, 5 Mar 2007 00:11:49 -0300

> Hi David, Stephen
> 
>        Whitespace cleanups have to pass the compile test too ;-) This
> is just in net-2.6.22 tho :-)
> 
> Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

I think I'll just revert Stephen's patch, both revisions were
done very sloppily, and this lack of compile testing basically
proves it. :-/
