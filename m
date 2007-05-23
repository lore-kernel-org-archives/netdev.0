From: jamal <hadi@cyberus.ca>
Subject: Re: Network activity LED trigger
Date: Wed, 23 May 2007 18:12:28 -0400
Message-ID: <1179958348.4082.30.camel@localhost>
References: <200705232302.43669.florian.fainelli@int-evry.fr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@sirena.org.uk>, netdev@vger.kernel.org,
	Richard Purdie <rpurdie@rpsys.net>
To: Florian Fainelli <florian.fainelli@int-evry.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:47813 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756699AbXEWWMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 May 2007 18:12:32 -0400
Received: by py-out-1112.google.com with SMTP id a73so555921pye
        for <netdev@vger.kernel.org>; Wed, 23 May 2007 15:12:32 -0700 (PDT)
In-Reply-To: <200705232302.43669.florian.fainelli@int-evry.fr>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


You know that you posted this exact message last time? ;->
And i responded here:
http://marc.info/?l=linux-netdev&m=117882888105536&w=2

cheers,
jamal

On Wed, 2007-23-05 at 23:02 +0200, Florian Fainelli wrote:
> Here comes a basic patch that adds a network led activity. It is not 
> configurable yet, but is enough to make a LED configured with 
> the "network-activity" trigger to blink on network activity.
> 
> Netdev people can probably comment on the place of ledtrig_network_activity(), 
> which is probably not adequate. Also the ledtrig_network_activity can be 
> network device specific for instance.
> 
> Signed-off-by: Florian Fainelli <florian.fainelli@int-evry.fr>

