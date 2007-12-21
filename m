From: "Sourav Chakraborty" <sourav1877@gmail.com>
Subject: Fwd: Increasing initial cwnd size
Date: Fri, 21 Dec 2007 15:19:55 +0530
Message-ID: <a5ed8fe60712210149m139a63fh28ec1c944d736f62@mail.gmail.com>
References: <a5ed8fe60712202358o7afc0bddhe77447d0d77631d8@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.178]:60309 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbXLUJt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Dec 2007 04:49:56 -0500
Received: by wa-out-1112.google.com with SMTP id v27so403561wah.23
        for <netdev@vger.kernel.org>; Fri, 21 Dec 2007 01:49:55 -0800 (PST)
In-Reply-To: <a5ed8fe60712202358o7afc0bddhe77447d0d77631d8@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

---------- Forwarded message ----------
From: Sourav Chakraborty <sourav1877@gmail.com>
Date: Dec 21, 2007 1:28 PM
Subject: Increasing initial cwnd size
To: linux-kernel@vger.kernel.org


Hello,

We are trying to test with kernel version 2.6.20,the RFC 3390
implementation of increased initial congestion window size(~4 when
MSS=1460 bytes).We are not getting consistent results
meaning,sometimes we see 4 data pkts sent without an ACK received and
sometimes we see 3.Also we would like to test by setting the initial
cwnd to a value more than 4.Can you guys advise us on how to do
that(where in the code should we change and what)?Also mention if
using linux 2.6.23 kernel instead of  the one we are using,would help
in this work.

Thanks and Regards
Sourav
