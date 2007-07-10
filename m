From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH re-resend] fix race in AF_UNIX garbage collector
Date: Tue, 10 Jul 2007 10:54:36 -0700 (PDT)
Message-ID: <20070710.105436.71090052.davem@davemloft.net>
References: <E1I8CMY-00053l-00@dorka.pomaz.szeredi.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	ebiederm@xmission.com, viro@ftp.linux.org.uk,
	alan@lxorguk.ukuu.org.uk, linux-kernel@vger.kernel.org
To: miklos@szeredi.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42305
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757332AbXGJRyO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 13:54:14 -0400
In-Reply-To: <E1I8CMY-00053l-00@dorka.pomaz.szeredi.hu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 10 Jul 2007 11:50:30 +0200

> Can you please add this to -mm.  Sometimes that has wonderful effect
> on the willingness of people to look at a patch.

No, I will merge this into my networking tree when I get the
chance to review your patch and it will automatically get into
-mm that way.

Please stop trying to rush this situation, it's driving me absolutely
bananas, and you're serving to tick me off rather than make me want to
review and go over your work.

You do this continuously, and it hurts rather than helps your cause,
so please cut it out.
