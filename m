From: "Malinen, Jouni" <jouni@qca.qualcomm.com>
Subject: Re: [PATCH v2 0/2] mac80211: use crypto shash for AES cmac
Date: Mon, 6 Feb 2017 10:01:08 +0000
Message-ID: <20170206100100.GA5905@jouni.qca.qualcomm.com>
References: <1486308208-3252-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "johannes@sipsolutions.net" <johannes@sipsolutions.net>,
        "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
To: "ard.biesheuvel@linaro.org" <ard.biesheuvel@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:32588 "EHLO
        wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750973AbdBFKB1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 05:01:27 -0500
In-Reply-To: <1486308208-3252-1-git-send-email-ard.biesheuvel@linaro.org>
Content-Language: en-US
Content-ID: <67D284FA99DD3F4F9DED7D4BABDA8CA0@qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Feb 05, 2017 at 03:23:26PM +0000, Ard Biesheuvel wrote:
> NOTE: Jouni has been so kind to test patch #2, and confirmed that it is w=
orking.
>       I have not tested patch #1 myself, mainly because the test methodol=
ogy
>       requires downloading Ubuntu installer images, and I am currently on=
 a
>       metered 3G connection (and will be for another couple of weeks)

These v2 patches pass the test cases as well.

(And you don't really need Ubuntu to run the hwsim test cases; any
reasonably recent distribution that is capable of running kvm should
work.)
=20
--=20
Jouni Malinen                                            PGP id EFC895FA=
