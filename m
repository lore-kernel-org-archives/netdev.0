From: "cramerj" <cramerj@intel.com>
Subject: RE: ethtool -d no longer works for e1000
Date: Wed, 9 Mar 2005 14:25:53 -0800
Message-ID: <76FA8CF8F1F53240BB5B962A3385A5800256F510@orsmsx405>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8bit
Content-class: urn:content-classes:message
To: "Ben Greear" <greearb@candelatech.com>, <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Perhaps the network interface enumeration changed with these kernels?
Is the e1000 part still eth0?

-Jeb

> -----Original Message-----
> From: netdev-bounce@oss.sgi.com [mailto:netdev-bounce@oss.sgi.com] On
> Behalf Of Ben Greear
> Sent: Wednesday, March 09, 2005 1:36 PM
> To: 'netdev@oss.sgi.com'
> Subject: ethtool -d no longer works for e1000
> 
> I tried this with FC2's 2.6.10-1.770_FC2smp kernel and with my own
> slightly hacked 2.6.11 kernel.  Both give this response:
> 
> ethtool -d eth0
> Cannot dump registers:  Success
> 
> I am quite certain this used to work, and used to show me
> the PCI bus speed and other nice details...
> 
> Thanks,
> Ben
> 
> --
> Ben Greear <greearb@candelatech.com>
> Candela Technologies Inc  http://www.candelatech.com
> 
