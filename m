From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH] tcp: Increase the initial congestion window to 10.
Date: Thu, 03 Feb 2011 15:43:28 +0100
Message-ID: <af0e6326c36977b0383bcac61f22b14f@localhost>
References: <20110202.170750.229739784.davem@davemloft.net>
 <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dccp@vger.kernel.org>, <therbert@google.com>
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alternativer.internetendpunkt.de ([88.198.24.89]:34837 "EHLO
	geheimer.internetendpunkt.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755282Ab1BCOn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 09:43:29 -0500
In-Reply-To: <47859e9273bb0c1b2c32fc1adfa450ee@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thu, 03 Feb 2011 15:00:28 +0100, Hagen Paul Pfeifer wrote:



> Davem, there is _no_ research how this huge IW will behave in

environments

> with a small BDP. Belief it or not, but there are networks out there

with a

> BDP similar to ~1980. Why for heaven's sake should this work in these

> environments? There are only _two_ extensive analysis one from Cherry

and



s/Cherry/Jerry/  ;-)



Hagen
