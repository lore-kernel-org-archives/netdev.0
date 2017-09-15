From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Fri, 15 Sep 2017 15:54:50 -0700
Message-ID: <252FFED5-906E-4D1B-9E87-679D0CE801D4@gmail.com>
References: <20170915222218.6613-1-rosenp@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
To: Rosen Penev <rosenp@gmail.com>, netdev@vger.kernel.org,
        zajec5@gmail.com, nbd@nbd.name
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:45819 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750871AbdIOWyz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 18:54:55 -0400
Received: by mail-pg0-f42.google.com with SMTP id 188so2284625pgb.2
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 15:54:55 -0700 (PDT)
In-Reply-To: <20170915222218.6613-1-rosenp@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 15, 2017 3:22:18 PM PDT, Rosen Penev <rosenp@gmail=2Ecom> wrot=
e:
>On a linksys E1200v1 (actually a crossflashed E1000v2), the offloading
>features give no measurable benefit to speed or latency=2E Furthermore,
>disabling GRO actually improves iperf performance by a whoppimg 3mbps=2E

Do you have a way to generate gigabit tests and see what results you are g=
etting? We probably are not going to see a 30% improvement just by extrapol=
ation=2E

--=20
Florian
