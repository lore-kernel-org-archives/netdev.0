From: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Subject: Re: ethtool -d no longer works for e1000
Date: Wed, 9 Mar 2005 14:09:45 -0800
Message-ID: <5fc59ff3050309140910f3e492@mail.gmail.com>
References: <422F6C37.8090202@candelatech.com>
Reply-To: Ganesh Venkatesan <ganesh.venkatesan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <422F6C37.8090202@candelatech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ben:

Are you using the e1000 that is included in the 2.6.11 kernel? ethtool
-d eth? works fine for me. What else is different in your env?

ganesh.


On Wed, 09 Mar 2005 13:35:51 -0800, Ben Greear <greearb@candelatech.com> wrote:
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
>
