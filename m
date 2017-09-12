From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net] mlxsw: spectrum: Prevent mirred-related crash on
 removal
Date: Tue, 12 Sep 2017 15:34:36 +0200
Message-ID: <20170912133436.GA9830@lunn.ch>
References: <20170912065053.1392-1-jiri@resnulli.us>
 <20170912130506.GB32598@lunn.ch>
 <20170912131550.GK2036@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, yuvalm@mellanox.com,
        idosch@mellanox.com, flokli@flokli.de, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:38273 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751313AbdILNei (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 12 Sep 2017 09:34:38 -0400
Content-Disposition: inline
In-Reply-To: <20170912131550.GK2036@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 12, 2017 at 03:15:50PM +0200, Jiri Pirko wrote:
> Tue, Sep 12, 2017 at 03:05:06PM CEST, andrew@lunn.ch wrote:
> >On Tue, Sep 12, 2017 at 08:50:53AM +0200, Jiri Pirko wrote:
> >> From: Yuval Mintz <yuvalm@mellanox.com>
> >
> >Hi Jiri, Yuval
> >
> >s/mirred/mirrored/g
> 
> Actually, the name of the tc action is indeed "mirred".

:-(

	Andrew
