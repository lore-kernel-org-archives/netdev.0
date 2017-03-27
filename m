From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH 1/1] ethtool : added
 get_phy_stats,get_strings,get_sset_count
Date: Mon, 27 Mar 2017 19:38:35 +0200
Message-ID: <20170327173835.GD17041@lunn.ch>
References: <1490609570-3571-1-git-send-email-thomasscariah@gmail.com>
 <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Scariah <thomasscariah@gmail.com>, nsekhar@ti.com,
        grygorii.strashko@ti.com, davem@davemloft.net,
        drivshin@allworx.com, mugunthanvnm@ti.com,
        ivan.khoronzhuk@linaro.org, thomas.scariah@harman.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:35705 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751482AbdC0RjI (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 27 Mar 2017 13:39:08 -0400
Content-Disposition: inline
In-Reply-To: <5153db09-092f-55b1-a8fc-aa23433c52a0@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 27, 2017 at 09:44:37AM -0700, Florian Fainelli wrote:
> Hello,
> 
> On 03/27/2017 03:12 AM, Thomas Scariah wrote:
> > From: "Scariah, Thomas" <thomas.scariah@harman.com>
> > 
> >  Added functions to support ethtool to print the phy statistics and error
> >  information along with other ethtool statistics. This will help ethtool
> >  information to know the error is from physical layer or MAC layer.
> >  This is an enahancement for ethtool to accommodate phy statistics

Hi Thomas

What tree is this against? net-next already has get_phy_stats,
get_strings, and get_sset_count in struct phy_driver.

     Andrew
