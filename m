From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] net: dsa: lan9303: unicast offload, fdb,mdb,STP
Date: Mon, 24 Jul 2017 13:32:01 -0700 (PDT)
Message-ID: <20170724.133201.1541272602104841059.davem@davemloft.net>
References: <525d9bb74bfa42c1b7a54930e14cf5ea@nooslMX1.zenitelcss.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: corbet@lwn.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, f.fainelli@gmail.com,
        kernel@pengutronix.de, linux-doc@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: egil.hjelmeland@zenitel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42546 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751579AbdGXUcE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 16:32:04 -0400
In-Reply-To: <525d9bb74bfa42c1b7a54930e14cf5ea@nooslMX1.zenitelcss.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Egil Hjelmeland <egil.hjelmeland@zenitel.com>
Date: Mon, 24 Jul 2017 16:47:51 +0200

> This is my first patches submitted to the kernel, so I am looking
> forward to comments.

Please clean up how the dates are handled in your submission.

They are all over the place, over a period of 3 days.

Instead, they should be consequentive, near the moment the patch is
submitted.

We manage patches in patchwork, and there the patches are ordered in
my queue based upon date.  So instead of a nice clean order of changes
showing up recently at the top of my queue, your's got mixed in deep
near the bottom of the queue, intermixed with other unrelated changes.

This seriously makes things more difficult for me.

The best thing to do is to apply your series into a fresh tree (which
you pretty much _MUST_ do anyways, to make sure your changes apply,
build and work properly in my GIT tree, right?) and then extract those
commits for your patch series emails.

You must also say in your subject line which of my two GIT networking
trees ('net' or 'net-next') your changes are targetting.  If you don't
know, you need to figure that out before submitting.

I'm not applying this series until you fix your process up.

Thank you.
