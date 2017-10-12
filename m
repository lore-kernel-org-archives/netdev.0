From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [RFC 0/3] Adding config get/set to devlink
Date: Thu, 12 Oct 2017 23:36:31 +0200
Message-ID: <20171012213631.5oewrd5fswas2vvu@unicorn.suse.cz>
References: <CAJieiUiFmBr72yYP9VNtm0VBTNjJcA6Lj5nHJNBjDBC4moxE2A@mail.gmail.com>
 <20171012150419.GI14672@nanopsycho>
 <24E5DE7C-A401-48BF-BF80-673ACC38FBBE@gmail.com>
 <20171012.120650.1063812043202847517.davem@davemloft.net>
 <21ab4a5d-0b6a-7976-7bf0-acd334f2613f@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
        roopa@cumulusnetworks.com, steven.lin1@broadcom.com,
        netdev@vger.kernel.org, jiri@mellanox.com,
        michael.chan@broadcom.com, linux-pci@vger.kernel.org,
        linville@tuxdriver.com, gospo@broadcom.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <21ab4a5d-0b6a-7976-7bf0-acd334f2613f@gmail.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2017 at 12:20:07PM -0700, Florian Fainelli wrote:
> On 10/12/2017 12:06 PM, David Miller wrote:
> > 
> > One suggestion is that devlink is used for getting ethtool stats for
> > objects lacking netdev representor's, and a new genetlink family is
> > used for netdev based ethtool.
> 
> Right, I was also thinking along those lines that we we would have a new
> generic netlink family for ethtool to support ethtool over netlink.

This is what I plan to work on on next SUSE Hackweek in November. But
I'm, of course, open to suggestions and I don't insist on this approach.

Michal Kubecek
