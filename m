From: =?UTF-8?B?QW5kcsOp?= Roth <neolynx@gmail.com>
Subject: Re: stmmac/RTL8211F/Meson GXBB: TX throughput problems
Date: Sun, 13 Nov 2016 20:20:20 +0100
Message-ID: <20161113202020.1acf2e1e@gmail.com>
References: <CAFBinCALSL_-izJ2tEsAjevAw90kGNTrQ3na3D1YV8f1dS1=Xg@mail.gmail.com>
        <ff6f3501-fbd5-3e79-dcc1-549406a5144b@st.com>
        <CAFBinCD42A_SqQz8GM-H+A32dMELknAytHuJ5T2YgZ3BrMKA3A@mail.gmail.com>
        <20160917232312.1e30d425@gmail.com>
        <d59f6e2c-15ff-779d-da2f-8eb5f5a535a6@st.com>
        <CAFBinCD_-KjVa70iOhBSGaXZc9uKy2m4d2yVr-AfLiV7F=3EqQ@mail.gmail.com>
        <1478190980.6632.26.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Martin Blumenstingl <martin.blumenstingl@googlemail.com>,
        Giuseppe CAVALLARO <peppe.cavallaro@st.com>,
        Johnson Leung <r58129@freescale.com>, netdev@vger.kernel.org,
        Alexandre Torgue <alexandre.torgue@st.com>,
        linux-amlogic@lists.infradead.org
To: Jerome Brunet <jbrunet@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35414 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932504AbcKMTUY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Nov 2016 14:20:24 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so9956186wme.2
        for <netdev@vger.kernel.org>; Sun, 13 Nov 2016 11:20:23 -0800 (PST)
In-Reply-To: <1478190980.6632.26.camel@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi all,

> To everybody having similar issue with their OdroidC2, could you try
> the attached patch and let us know if it changes anything for you ?

I can confirm that this patch removes the problem, I have now constant
~300Mb/s in both directions without any issue ! :)

I used the v4.10/integ branch, which shows the problem without applying
this patch.=20

Thanks for your work,

 Andr=C3=A9=20
