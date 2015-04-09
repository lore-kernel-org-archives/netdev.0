From: Stefan Bauer <sb@plzk.de>
Subject: Re: ip link macvtap interface not processing specific ipv6
 multicast traffic without promiscuous mode on
Date: Thu, 09 Apr 2015 18:51:28 +0200
Message-ID: <1428598288.2759.2.camel@plzk.de>
References: <1428574167.2171.32.camel@plzk.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay04.ispgateway.de ([80.67.31.38]:37493 "EHLO
	smtprelay04.ispgateway.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932717AbbDIREe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 13:04:34 -0400
Received: from [91.47.193.61] (helo=zarafa)
	by smtprelay04.ispgateway.de with esmtpsa (TLSv1.2:DHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.84)
	(envelope-from <sb@plzk.de>)
	id 1YgFft-0000qq-0d
	for netdev@vger.kernel.org; Thu, 09 Apr 2015 18:51:29 +0200
Received: from s1 (unknown [192.168.0.151])
	by zarafa (Postfix) with ESMTP id 1885B220064
	for <netdev@vger.kernel.org>; Thu,  9 Apr 2015 18:51:28 +0200 (CEST)
In-Reply-To: <1428574167.2171.32.camel@plzk.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Seems to be a problem with the VM guests.

Works with linux guests out of the box.
Does only not work with win10 guests.

Sorry for the noise :/

Stefan
