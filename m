From: <Joe.Ghalam@dell.com>
Subject: Re: macvlan: Fix device ref leak when purging bc_queue
Date: Tue, 25 Apr 2017 15:19:02 +0000
Message-ID: <1493133542320.84322@Dell.com>
References: <1492618528011.11322@Dell.com>
        <20170420125512.GA9113@gondor.apana.org.au>,<20170425.104254.1884694182452846750.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: <Clifford.Wichmann@dell.com>, <netdev@vger.kernel.org>
To: <davem@davemloft.net>, <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa8.dell-outbound.iphmx.com ([68.232.149.218]:39686 "EHLO
        esa8.dell-outbound.iphmx.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1949598AbdDYPTt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 11:19:49 -0400
In-Reply-To: <20170425.104254.1884694182452846750.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>=0A=
Sent: Tuesday, April 25, 2017 7:42 AM=0A=
To: herbert@gondor.apana.org.au=0A=
Cc: Ghalam, Joe; Wichmann, Clifford; netdev@vger.kernel.org=0A=
Subject: Re: macvlan: Fix device ref leak when purging bc_queue=0A=
=0A=
> Applied and queued up for -stable, thanks Herbert.=0A=
=0A=
Herbert and David,=0A=
Glad to report that we had 10 iterations of the test that was showing 100% =
failure with Herbert's changes, and we have not seen any failures. The fix =
is good.=0A=
Thanks for the help.=0A=
Joe=0A=
