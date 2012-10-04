From: Eugenia Emantayev <eugenia@mellanox.com>
Subject: RE: [PATCH 3/3] net/mlx4_en: Add HW timestamping (TS) support
Date: Thu, 4 Oct 2012 20:58:59 +0000
Message-ID: <74A0102445410646AFACC089FD94803A95ED9341@MTLDAG01.mtl.com>
References: <1348826603-17439-1-git-send-email-yevgenyp@mellanox.com>
 <1348826603-17439-4-git-send-email-yevgenyp@mellanox.com>
 <20120928111147.GA7474@netboy.at.omicron.at>
 <74A0102445410646AFACC089FD94803A95ED92DD@MTLDAG01.mtl.com>
 <20121004142734.GA2810@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Yevgeny Petrilin <yevgenyp@mellanox.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Or Gerlitz" <ogerlitz@mellanox.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog101.obsmtp.com ([207.126.144.111]:47614 "HELO
	eu1sys200aog101.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757319Ab2JDU7I convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 16:59:08 -0400
In-Reply-To: <20121004142734.GA2810@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> You could register the driver as PHC class device, described in
>
>   Documentation/ptp/ptp.txt
>
> and then you device will work together along with a user space PTP stack, like the one I wrote at
>
>   http://linuxptp.sourceforge.net


Richard,

Thanks for the explanation.
At this stage we prefer to submit the initial patch set (V1) and then, at the next phase,
extend it as you suggested above, after learning and better understanding the requirements
and effects.

Regards,
Eugenia
