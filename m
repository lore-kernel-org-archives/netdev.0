From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Bonding-devel] [PATCH 2/3] bonding: only receive ARPs for us
Date: Fri, 02 Mar 2007 20:41:18 -0500
Message-ID: <45E8D23E.40909@garzik.org>
References: <200703010103.l2113R22030799@death.nxdomain.ibm.com> <45E8CEB0.3070204@garzik.org> <3729.1172885902@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:55840 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992891AbXCCBlT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:41:19 -0500
In-Reply-To: <3729.1172885902@death>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Jeff Garzik <jeff@garzik.org> wrote:
> 
>> Jay Vosburgh wrote:
>>> 	The ARP validation code only needs ARPs for the bonding device.
>>>
>>> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
>> I seem to have lost the context of this.  Did this get discussed, and 
>> need further revision?
> 
> 	The further discussion can be (loosely) paraphrased as:
> 
> Andy Gospodarek <andy@greyhouse.net>: "Hey, this no workee with IPv6."
> 
> Me: "True, but bonding no workee with IPv6 at all."
> 
> Andy: "Oh, ok.  Ack."
> 
> 	After which followed some preliminary yakkage about fixing up
> said non-workee IPv6 support.

thanks :)  I'll make sure the 3 patches go into #upstream-fixes


