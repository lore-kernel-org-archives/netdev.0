From: Jens Rottmann <JRottmann@LiPPERTEmbedded.de>
Subject: Re: ethtool -E rejects magic >= 80000000
Date: Mon, 06 Jun 2011 15:39:51 +0200
Message-ID: <4DECD8A7.4070605@LiPPERTEmbedded.de>
References: <4DECA785.7070207@LiPPERTEmbedded.de>	 <1307355820.2765.15.camel@bwh-desktop> <1307357436.2765.20.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Martin Hein <MHein@LiPPERTEmbedded.com>,
	Jeff Garzik <jgarzik@redhat.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.lippert-at.com ([62.80.22.186]:48563 "EHLO
	domex.lippertembedded.de" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750877Ab1FFNzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:55:13 -0400
In-Reply-To: <1307357436.2765.20.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben,

> Please can you test the attached patch ...

Tested on top of ethtool 2.6.39, works fine.

Thanks!
Jens
