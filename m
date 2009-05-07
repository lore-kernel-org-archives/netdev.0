From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Help interpreting MII negotiation
Date: Thu, 07 May 2009 03:55:12 +0100
Message-ID: <1241664912.29051.18.camel@deadeye>
References: <9e4733910905061903x693ca36av38ff4cc9aef4ce38@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jon Smirl <jonsmirl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:37237 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752078AbZEGCzQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2009 22:55:16 -0400
In-Reply-To: <9e4733910905061903x693ca36av38ff4cc9aef4ce38@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-05-06 at 22:03 -0400, Jon Smirl wrote:
> I don't understand why speed selection is getting set at 10Mbps in this example.
> It looks to me like the devices auto negotiated 100Mbps.
[...]

The "speed selection" bits have no meaning unless auto-negotiation is
disabled.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
