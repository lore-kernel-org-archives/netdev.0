From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/4] net: dsa: lan9303: MDIO access phy
 registers directly
Date: Fri, 28 Jul 2017 23:28:40 +0200
Message-ID: <20170728212840.GC11564@lunn.ch>
References: <20170728151157.28983-1-privat@egil-hjelmeland.no>
 <20170728151157.28983-5-privat@egil-hjelmeland.no>
 <87fudglget.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <50d2d34c-c1a5-7f0a-90f1-44b1be1775b7@egil-hjelmeland.no>
 <87fudgqz4w.fsf@weeman.i-did-not-set--mail-host-address--so-tickle-me>
 <1250382a-1c17-8e82-8c5c-fe14786c84db@gmail.com>
 <a8ff8b7b-5aff-f25b-5ad3-944fcc867e40@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@pengutronix.de
To: Egil Hjelmeland <privat@egil-hjelmeland.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <a8ff8b7b-5aff-f25b-5ad3-944fcc867e40@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> >Since the kernel module license is GPL, EXPORT_SYMBOL_GPL() would seem
> >to be appropriate, which can be done as a subsequent patch.
> >
> >Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> >
> I have no idea how these legalities work. But for the record,
> I give consent to change to EXPORT_SYMBOL_GPL at any time.

Hi Egil

What is better, is that when somebody posts such a patch, send an
Acked-by: It will get added to the patch, leaving a record in git that
you agreed to the change.

    Andrew
