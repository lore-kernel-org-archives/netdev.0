From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Wed, 6 Sep 2017 19:09:22 +0200
Message-ID: <20170906170922.GG15315@lunn.ch>
References: <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
 <20170829074547.GB31303@amd>
 <93AF473E2DA327428DE3D46B72B1E9FD4111FA48@CHN-SV-EXMX02.mchp-main.com>
 <CAJGZr0+WueUjZJTLmcJRXtLtgUTUGnPCgiHQir=v5cRf3ido_g@mail.gmail.com>
 <93AF473E2DA327428DE3D46B72B1E9FD41120E4D@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: muvarov@gmail.com, pavel@ucw.cz, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Tristram.Ha@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58897 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754807AbdIFRJ1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 6 Sep 2017 13:09:27 -0400
Content-Disposition: inline
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41120E4D@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> The patches are under review internally and will need to be updated
> and approved by Woojung before formal submission.  Problem is
> although KSZ8795 and KSZ8895 drivers are new code and will be
> submitted as RFC, they depend on the change of KSZ9477 driver
> currently in the kernel, which require more rigorous review.

Please be aware that they will also go though review when you post
them. This can be anything from great, nice job, to throw them away
and start again. Since you are submitting RFCs we understand it is
early code, issues still to be solved, and we can make suggestions how
to solve those issues.

Post early, post often...

     Andrew
