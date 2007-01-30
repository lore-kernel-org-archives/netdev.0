From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [Fwd: Re: wan/pc300 bug found]
Date: Tue, 30 Jan 2007 16:00:29 +0100
Message-ID: <m3lkjk5zle.fsf@maximus.localdomain>
References: <4559D5BF.3080605@garzik.org> <m3k61ydnv4.fsf@defiant.localdomain>
	<458423C3.2080002@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Netdev List <netdev@vger.kernel.org>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:51108 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965579AbXA3PAc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jan 2007 10:00:32 -0500
In-Reply-To: <458423C3.2080002@garzik.org> (Jeff Garzik's message of "Sat, 16 Dec 2006 11:50:11 -0500")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Jeff Garzik <jeff@garzik.org> writes:

>> I have a driver for PC300/RSV (dual V.35 + V.24) for years. I'm told
>> it works with X.21 version too. If someone has a spare T1/E1 card
>> (non-returnable donation only) I can try to add support as well.
>> T1/E1 is too complicated to maintain without the actual hardware.
>> Perhaps we should add my driver to the tree, mark the old one as
>> obsolete and look for angry reports from T1/E1 users?
>
> No objections...

Great. I'm not marking the original pc300 driver as obsolete
- should I? It supports (at least theoretically) multi line PPP
and PC300 T1/E1, my drivers don't.
-- 
Krzysztof Halasa
