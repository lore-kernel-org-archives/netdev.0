From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH v6 5/8] thunderbolt: Networking state machine
Date: Wed, 31 Aug 2016 13:35:23 +0200
Message-ID: <20160831113523.GF17607@kroah.com>
References: <1470054233-4309-1-git-send-email-amir.jer.levy@intel.com>
 <1470054233-4309-6-git-send-email-amir.jer.levy@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andreas.noever@gmail.com, bhelgaas@google.com, corbet@lwn.net,
        linux-kernel@vger.kernel.org, linux-pci@vger.kernel.org,
        netdev@vger.kernel.org, linux-doc@vger.kernel.org,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com
To: Amir Levy <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1470054233-4309-6-git-send-email-amir.jer.levy@intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 01, 2016 at 03:23:50PM +0300, Amir Levy wrote:
> Negotiation states that a peer goes through in order to establish
> the communication with the second peer.

I can not parse that sentance, what exactly does that mean?

> This includes communication with upper layer and additional
> infrastructure support to communicate with the second peer through ICM.

This too is unparsable.  Please explain what this patch does in terms
that are understandable for someone with at least a passing
understanding of hardware busses.  As it is, I have no idea what this
patch does at all, and I should be your target audience for this
changelog.

thanks,

greg k-h
