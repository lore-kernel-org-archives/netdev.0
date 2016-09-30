From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v8 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Fri, 30 Sep 2016 02:40:26 -0400 (EDT)
Message-ID: <20160930.024026.274720546666401005.davem@davemloft.net>
References: <1475073870-2126-1-git-send-email-amir.jer.levy@intel.com>
        <20160930.015555.2177533749954623343.davem@davemloft.net>
        <20160930063005.GA7571@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amir.jer.levy@intel.com, andreas.noever@gmail.com,
        bhelgaas@google.com, corbet@lwn.net, linux-kernel@vger.kernel.org,
        linux-pci@vger.kernel.org, netdev@vger.kernel.org,
        linux-doc@vger.kernel.org, mario_limonciello@dell.com,
        thunderbolt-linux@intel.com, mika.westerberg@intel.com,
        tomas.winkler@intel.com, xiong.y.zhang@intel.com
To: gregkh@linuxfoundation.org
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <20160930063005.GA7571@kroah.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greg KH <gregkh@linuxfoundation.org>
Date: Fri, 30 Sep 2016 08:30:05 +0200

> On Fri, Sep 30, 2016 at 01:55:55AM -0400, David Miller wrote:
>> From: Amir Levy <amir.jer.levy@intel.com>
>> Date: Wed, 28 Sep 2016 17:44:22 +0300
>> 
>> > This driver enables Thunderbolt Networking on non-Apple platforms
>> > running Linux.
>> 
>> Greg, any idea where this should get merged once fully vetted?  I can
>> take it through the net-next tree, but I'm fine with another more
>> appropriate tree taking it as well.
> 
> I am supposed to be taking thunderbolt patches, but if this really is a
> network driver, it should go under drivers/net/ somewhere.  It needs
> more review though, it's not ready to go through anyone's tree just yet :)
> 
> I'll let the thunderbolt maintainer go through it first before asking
> for a netdev review.

Ok, thanks Greg.
