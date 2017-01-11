From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Marvell Phy (1510) issue since v4.7 kernel
Date: Thu, 12 Jan 2017 00:22:00 +0100
Message-ID: <20170111232200.GI13033@lunn.ch>
References: <20170109225641.GB22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545A3@DFLE11.ent.ti.com>
 <20170109235534.GH22820@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E153545C9@DFLE11.ent.ti.com>
 <20170110015336.GA7160@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AC2@DFLE11.ent.ti.com>
 <20170111222758.GG13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354AE5@DFLE11.ent.ti.com>
 <20170111225948.GH13033@lunn.ch>
 <230CBA6E4B6B6B418E8730AC28E6FC7E15354B2B@DFLE11.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "rmk+kernel@arm.linux.org.uk" <rmk+kernel@arm.linux.org.uk>,
        "charles-antoine.couret@nexvision.fr"
        <charles-antoine.couret@nexvision.fr>,
        "Karicheri, Muralidharan" <m-karicheri2@ti.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57842 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751749AbdAKXWL (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Jan 2017 18:22:11 -0500
Content-Disposition: inline
In-Reply-To: <230CBA6E4B6B6B418E8730AC28E6FC7E15354B2B@DFLE11.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > So i think the correct question should be, how can we tell the 88E1512
> > from the 88E1510 if they have the same ID in register 3.

Hi WingMan

Do you know you really have a 1510? You can see it written on the
chip?

Please can you read page 18, register 30 and let us know what value
you get.

    Andrew
