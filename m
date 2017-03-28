From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/7] Documentation: dt: net: Update the ath9k binding for
 SoC devices
Date: Tue, 28 Mar 2017 18:41:59 +0200
Message-ID: <20170328164159.GB29742@lunn.ch>
References: <1489439116-4233-1-git-send-email-albeu@free.fr>
 <2357006.NGKQYCh4BG@debian64>
 <20170328151837.GC3152@lunn.ch>
 <8622591.q4sXytZqXW@debian64>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alban <albeu@free.fr>,
        QCA ath9k Development <ath9k-devel@qca.qualcomm.com>,
        John Crispin <john@phrozen.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        Rob Herring <robh+dt@kernel.org>,
        Mark Rutland <mark.rutland@arm.com>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        m@kresin.me
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <8622591.q4sXytZqXW@debian64>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Oh, in that case you should probably go "all out" and ask on the 
> LKML to remove all of the ath9k and ath10k ahb work. From what I
> know all the "users" are running some sort of OpenWRT/LEDE or a 
> derivative. This is because Atheros/QCA provided a SDK based on
> OpenWRT.
> 
> Alban has been trying to convert the platform to device-tree
> and add them to the mainline for a while now:
>  
> https://patchwork.kernel.org/patch/6514551/
> 
> So, you are questioning this work as well.

Not at all. Ralph Sennhauser has been doing a great job of getting all
the Marvell devices into Mainline, and i help as much as i can, being
one of the Marvell SoC Maintainers.

I'm just saying, get a few boards which require these facilities into
the mainline, and then you have a much stranger base to argue from.

    Andrew
