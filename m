From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [Fwd: Re: wan/pc300 bug found]
Date: Sat, 16 Dec 2006 11:50:11 -0500
Message-ID: <458423C3.2080002@garzik.org>
References: <4559D5BF.3080605@garzik.org> <m3k61ydnv4.fsf@defiant.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:34896 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161191AbWLPQuQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Dec 2006 11:50:16 -0500
To: Krzysztof Halasa <khc@pm.waw.pl>
In-Reply-To: <m3k61ydnv4.fsf@defiant.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Krzysztof Halasa wrote:
> Jeff Garzik <jeff@garzik.org> writes:
> 
>> FYI...  I'm certainly willing to remove pc300, if nobody wants it.
>>
>> But I am unsure whether this is a case of "vendor doesn't care" or
>> "users don't care", which are two very different things...
> 
> I have a driver for PC300/RSV (dual V.35 + V.24) for years. I'm told
> it works with X.21 version too. If someone has a spare T1/E1 card
> (non-returnable donation only) I can try to add support as well.
> 
> T1/E1 is too complicated to maintain without the actual hardware.
> 
> Perhaps we should add my driver to the tree, mark the old one as
> obsolete and look for angry reports from T1/E1 users?

No objections...

	Jeff



