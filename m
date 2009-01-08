From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Re: [BUG #12364] Re: HTB - very bad precision? HFSC works fine!     2.6.28
Date: Thu, 8 Jan 2009 20:46:07 +0200
Message-ID: <200901082046.07857.denys@visp.net.lb>
References: <1935.87.196.72.187.1231371721.squirrel@webmail.decimal.pt> <200901082032.16859.denys@visp.net.lb> <3827.192.168.1.3.1231439836.squirrel@webmail.decimal.pt>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Jarek Poplawski" <jarkao2@gmail.com>, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: "Jorge Bastos" <mysql.jorge@decimal.pt>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:60721 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757738AbZAHSqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Jan 2009 13:46:06 -0500
In-Reply-To: <3827.192.168.1.3.1231439836.squirrel@webmail.decimal.pt>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

on this interface 

Router-Dora /config # ethtool -i eth0
driver: e1000e
version: 0.3.3.3-k6
firmware-version: 2.1-11
bus-info: 0000:04:00.0

Router-Dora /config # ethtool eth0
Settings for eth0:
        Supported ports: [ TP ]
        Supported link modes:   10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Supports auto-negotiation: Yes
        Advertised link modes:  10baseT/Half 10baseT/Full
                                100baseT/Half 100baseT/Full
                                1000baseT/Full
        Advertised auto-negotiation: Yes
        Speed: 1000Mb/s
        Duplex: Full
        Port: Twisted Pair
        PHYAD: 1
        Transceiver: internal
        Auto-negotiation: on
        Supports Wake-on: pumbag
        Wake-on: g
        Current message level: 0x00000001 (1)
        Link detected: yes


On Thursday 08 January 2009 20:37:16 Jorge Bastos wrote:
> What's your NIC?
> Speed, and driver that you are using.
>
