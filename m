From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 3/7] crypto:gf128mul: The x8_ble multiplication functions
Date: Tue, 3 Oct 2017 14:58:12 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0088A2B@AcuExch.aculab.com>
References: <cover.1507010612.git.harsh@chelsio.com>
 <3e443f7a245229a2752fcf21dfed10998847e345.1507010612.git.harsh@chelsio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Harsh Jain' <harsh@chelsio.com>,
        "herbert@gondor.apana.org.au" <herbert@gondor.apana.org.au>,
        "linux-crypto@vger.kernel.org" <linux-crypto@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.194]:57523 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751874AbdJCO6P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 10:58:15 -0400
In-Reply-To: <3e443f7a245229a2752fcf21dfed10998847e345.1507010612.git.harsh@chelsio.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harsh Jain
> Sent: 03 October 2017 07:46
> It multiply GF(2^128) elements in the ble format.
> It will be used by chelsio driver to fasten gf multiplication.
                                       ^ speed up ??

	David
