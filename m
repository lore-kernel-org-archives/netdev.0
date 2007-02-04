From: Ulrich Kunitz <kune@deine-taler.de>
Subject: Re: Wireless network card capabilities
Date: Sun, 4 Feb 2007 13:27:21 +0100
Message-ID: <20070204122721.GA2280@p15091797.pureserver.info>
References: <45C5B892.3000507@superbug.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Courtier-Dutton <James@superbug.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from deine-taler.de ([217.160.107.63]:49469 "EHLO
	p15091797.pureserver.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751977AbXBDM1X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Feb 2007 07:27:23 -0500
Content-Disposition: inline
In-Reply-To: <45C5B892.3000507@superbug.co.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07-02-04 10:42 James Courtier-Dutton wrote:

> Hi,
> 
> Can Wireless network cards receive and transmit on two channels at once?
> I am thinking of implementing a way for a wireless VoIP phone on Linux 
> being able to hand off from one AP to another without dropping the call.
> For this to work, the wireless card must be able to chat on two channels 
> during the handover, so as to not loose any voice packets.
> 
> James

The easiest way to achieve this is to use two wireless adapters.
I'm not sure, whether there are adapters, which support parallel
reception on two channels and manage two independent
associations at the same time. 

-- 
Uli Kunitz
