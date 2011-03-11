From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 00/11][pull request] Intel Wired LAN Driver
 Updates
Date: Fri, 11 Mar 2011 15:03:38 -0800 (PST)
Message-ID: <20110311.150338.193701255.davem@davemloft.net>
References: <1299841590-30676-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<20110311.110629.193721476.davem@davemloft.net>
	<1299854851.2852.7.camel@jtkirshe-MOBL1>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45647
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751922Ab1CKXDC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2011 18:03:02 -0500
In-Reply-To: <1299854851.2852.7.camel@jtkirshe-MOBL1>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Fri, 11 Mar 2011 06:47:31 -0800

> On Fri, 2011-03-11 at 11:06 -0800, David Miller wrote:
>> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>> Date: Fri, 11 Mar 2011 03:06:19 -0800
>> 
>> > The following series contains FCoE documentation update, ixgb conversion
>> > to the new VLAN model, several fixes and cleanups for e1000e and
>> > the removal of Tx hang detection in ixgbevf (like recent igbvf patch).
>> > 
>> > The following are changes since commit 1b7fe59322bef9e7a2c05b64a07a66b875299736:
>> >   ipv4: Kill flowi arg to fib_select_multipath()
>> > 
>> > and are available in the git repository at:
>> >   master.kernel.org:/pub/scm/linux/kernel/git/jkirsher/net-next-2.6 master
>> 
>> Does this one actually compile? :-)
> 
> Yes, it does.  Sorry about the last one, both Emil and I had found the
> issue when I applied the patch to my internal testing tree and I
> manually fixed up the compile issue, but forgot to send out the updated
> patch to our patchwork server.
> 
> I personally double checked the compilation of every single patch in
> this pull request.

Ok, good to hear, pulled :-)
