From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2003@gmx.net>
Subject: Re: [Forcedeth] Wake-on-LAN support?
Date: Tue, 20 Jan 2004 05:22:03 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <400CACEB.6050307@gmx.net>
References: <Pine.GHP.4.44.0401121152250.1675-100000@elektron.its.tudelft.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, len.brown@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: a.verweij@student.tudelft.nl
In-Reply-To: <Pine.GHP.4.44.0401121152250.1675-100000@elektron.its.tudelft.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Arjen Verweij wrote:
> L.S.,
> 
> First, many thanks for your efforts. The driver works beautifully here,
> with 2.4.23 and 2.6.0-test11 alike.
> 
> I was wondering if it is possible to add Wake-on-LAN support to the
> driver. NVidia claims their binary driver supports WOL, but it doesn't
> work one bit. It is possible to look into this?
> 
> I have filed a bugtracker with the ACPI people, but they are somewhat
> understandably preoccupied with fixing laptop woes.
> 
> URL:
> http://bugzilla.kernel.org/show_bug.cgi?id=1636
> 
> I am able to enable WOL at shutdown with pci-config from scyld.com, but
> this is obviously an ugly fix.

Hmmm... normally I would say enabling WOL is the job of the BIOS.

Comments anyone?

Setting Wake-on-LAN patterns will be supported in a future version of
forcedeth but right now I'm swamped with university work.


Carl-Daniel
-- 
http://www.hailfinger.org/
