From: "Belgazal, Netanel" <netanel@amazon.com>
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver
Date: Sun, 11 Jun 2017 12:28:00 +0000
Message-ID: <1497184080973.92112@amazon.com>
References: <1497046437-20390-1-git-send-email-netanel@amazon.com>
        <fac900d3-dae3-1c88-ceef-d28294ed7941@gmail.com>,<20170610.161133.722413665016881379.davem@davemloft.net>
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
To: David Miller <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.190.10]:43161 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751631AbdFKM2i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 11 Jun 2017 08:28:38 -0400
In-Reply-To: <20170610.161133.722413665016881379.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ack.=0A=
resubmitting to net branch and adding "Fixes" mark.=0A=
________________________________________=0A=
From: David Miller <davem@davemloft.net>=0A=
Sent: Saturday, June 10, 2017 11:11 PM=0A=
To: f.fainelli@gmail.com=0A=
Cc: Belgazal, Netanel; netdev@vger.kernel.org; Woodhouse, David; Machulsky,=
 Zorik; Matushevsky, Alexander; BSHARA, Said; Wilson, Matt; Liguori, Anthon=
y; Bshara, Nafea; Schmeilin, Evgeny=0A=
Subject: Re: [PATCH net-next 0/8] Bug fixes in ena ethernet driver=0A=
=0A=
From: Florian Fainelli <f.fainelli@gmail.com>=0A=
Date: Fri, 9 Jun 2017 15:19:54 -0700=0A=
=0A=
> On 06/09/2017 03:13 PM, netanel@amazon.com wrote:=0A=
>> From: Netanel Belgazal <netanel@amazon.com>=0A=
>>=0A=
>> This patchset contains fixes for the bugs that were discovered so far.=
=0A=
>=0A=
> If these are all fixes you should submit them against the "net" tree.=0A=
> net-next is for features [1].=0A=
>=0A=
> Since these are fixes, you may also want to provide a Fixes: 12-digit=0A=
> commit ("commit subject") [2] such that David can queue these patches=0A=
> for stable trees and this can be retrofitted into kernel distributions.=
=0A=
>=0A=
> [1]:=0A=
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/networking/netdev-FAQ.txt#n25=0A=
>=0A=
> [2]:=0A=
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/D=
ocumentation/process/submitting-patches.rst#n183=0A=
=0A=
Yeah I agree.  If they are genuine bug fixes they should be submitted=0A=
against 'net'.  And yes, Fixes: tags are quite desirable as well.=0A=
=0A=
