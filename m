From: Mika Westerberg <mika.westerberg@linux.intel.com>
Subject: Re: [PATCH 06/16] thunderbolt: Add support for XDomain discovery
 protocol
Date: Tue, 19 Sep 2017 10:40:56 +0300
Message-ID: <20170919074056.GF4630@lahna.fi.intel.com>
References: <20170918153049.44185-1-mika.westerberg@linux.intel.com>
 <20170918153049.44185-7-mika.westerberg@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Noever <andreas.noever@gmail.com>,
        Michael Jamet <michael.jamet@intel.com>,
        Yehezkel Bernat <yehezkel.bernat@intel.com>,
        Amir Levy <amir.jer.levy@intel.com>,
        Mario.Limonciello@dell.com, Lukas Wunner <lukas@wunner.de>,
        Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170918153049.44185-7-mika.westerberg@linux.intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 18, 2017 at 06:30:39PM +0300, Mika Westerberg wrote:
> +What:		/sys/bus/thunderbolt/devices/<xdomain>.<service>/key
> +Date:		Dec 2017
> +KernelVersion:	4.14

I forgot to update these to 4.15. I'll fix them in v2.
