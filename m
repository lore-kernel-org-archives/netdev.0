From: "Belgazal, Netanel" <netanel@amazon.com>
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver
Date: Fri, 9 Jun 2017 07:13:53 +0000
Message-ID: <1496992430966.5282@amazon.com>
References: <1496958410-4220-1-git-send-email-netanel@amazon.com>,<20170608.191712.1829919738916549276.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Woodhouse, David" <dwmw@amazon.co.uk>,
        "Machulsky, Zorik" <zorik@amazon.com>,
        "Matushevsky, Alexander" <matua@amazon.com>,
        "BSHARA, Said" <saeedb@amazon.com>,
        "Wilson, Matt" <msw@amazon.com>,
        "Liguori, Anthony" <aliguori@amazon.com>,
        "Bshara, Nafea" <nafea@amazon.com>,
        "Schmeilin, Evgeny" <evgenys@amazon.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-9102.amazon.com ([207.171.184.29]:55162 "EHLO
        smtp-fw-9102.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdFIHO1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 03:14:27 -0400
In-Reply-To: <20170608.191712.1829919738916549276.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

My apologies,=0A=
I was not aware.=0A=
Will make sure this won't happen again.=0A=
=0A=
Regards,=0A=
Netanel=0A=
________________________________________=0A=
From: David Miller <davem@davemloft.net>=0A=
Sent: Friday, June 9, 2017 2:17 AM=0A=
To: Belgazal, Netanel=0A=
Cc: netdev@vger.kernel.org; Woodhouse, David; Machulsky, Zorik; Matushevsky=
, Alexander; BSHARA, Said; Wilson, Matt; Liguori, Anthony; Bshara, Nafea; S=
chmeilin, Evgeny=0A=
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver=0A=
=0A=
Two parallel patch series to the same driver and targetting the=0A=
same GIT tree is extremely undesirable, please don't do this.=0A=
=0A=
Submit one series, and once applied submit the second series.=0A=
=0A=
I'm deleting all of your patches from my queue, please resubmit=0A=
things properly.=0A=
=0A=
Thank you.=0A=
