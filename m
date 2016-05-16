From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [tipc-discussion] [PATCH net-next] tipc: check nl sock before
 parsing nested attributes
Date: Mon, 16 May 2016 08:07:10 -0700
Message-ID: <1463411230.18194.86.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1463390094-9235-1-git-send-email-richard.alpe@ericsson.com>
	 <A2BAEFC30C8FD34388F02C9B3121859D224888AF@eusaamb103.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Alpe <richard.alpe@ericsson.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"sploving1@gmail.com" <sploving1@gmail.com>,
	"tipc-discussion@lists.sourceforge.net"
	<tipc-discussion@lists.sourceforge.net>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35981 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbcEPPHN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 11:07:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id g132so15985754pfb.3
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 08:07:12 -0700 (PDT)
In-Reply-To: <A2BAEFC30C8FD34388F02C9B3121859D224888AF@eusaamb103.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-16 at 14:06 +0000, Jon Maloy wrote:
> This is a serious bug, so it should be posted to net, not net-next.
> 
> Otherwise,
> Acked-by: Jon Maloy <jon.maloy@ericsson.cm>

Well, linux-4.6 is out, so it does not really matter.

Next push from David will use his net-next tree.

Thanks.
