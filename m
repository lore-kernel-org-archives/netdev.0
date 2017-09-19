From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: aquantia: default to no in config
Date: Tue, 19 Sep 2017 15:59:21 -0700 (PDT)
Message-ID: <20170919.155921.343695983211850627.davem@davemloft.net>
References: <20170919224315.GA17797@shells.gnugeneration.com>
        <20170919.155231.1474915838737685519.davem@davemloft.net>
        <20170919230249.GB17797@shells.gnugeneration.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: vcaputo@pengaru.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170919230249.GB17797@shells.gnugeneration.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: vcaputo@pengaru.com
Date: Tue, 19 Sep 2017 16:02:49 -0700

> Out of curiosity, what's the rationale for that decision?

So that you don't need to know what special vendor knob needs to be
switched in order to even be offered the config knob for the driver
you are interested in.
