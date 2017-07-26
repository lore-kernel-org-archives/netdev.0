From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/10] net: dsa: lan9303: Fixed MDIO interface
Date: Wed, 26 Jul 2017 23:39:43 +0200
Message-ID: <20170726213943.GA7966@lunn.ch>
References: <87999a6c-4ea8-ba4c-e2db-cdb37c1c8c8a@egil-hjelmeland.no>
 <87lgnbgtiq.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <20170726175224.GT12049@lunn.ch>
 <20170726.130747.9593997952509805.davem@davemloft.net>
 <7a0d712b-1626-a4e5-e366-a626bdafc6cf@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        vivien.didelot@savoirfairelinux.com, corbet@lwn.net,
        f.fainelli@gmail.com, kernel@pengutronix.de,
        linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-doc-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <7a0d712b-1626-a4e5-e366-a626bdafc6cf@egil-hjelmeland.no>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Good. Just one question about process. Could I have posted my work
> as a RFC? To get one round of initial feedback before chopping into
> small patch requests. As well as indicating where I am heading. Or is
> that just waste of human bandwidth?

Depends. Post 100 RFC patches, i won't look at them. Post 21 with a
cover note making it clear you are planning to submit them in blocks
of 7, i might.

But it is best to assume reviewers have small blocks of time. 21
patches take 3 times a long to review as 7. The block of time might
not be enough for 21, so the review gets differed. 7 are more likely
to fit in the available time, so it happens quickly.

   Andrew
