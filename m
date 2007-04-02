From: Rick Jones <rick.jones2@hp.com>
Subject: NIC data corruption
Date: Mon, 02 Apr 2007 10:46:00 -0700
Message-ID: <46114158.2030007@hp.com>
References: <20070401012736.GT15189@vitelus.com>	<20070401030315.GA24080@jim.sh> <20070401043905.GV15189@vitelus.com> <p737iswqjq4.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Aaron Lehmann <aaronl@vitelus.com>, Jim Paris <jim@jtan.com>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:60536 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752900AbXDBRqE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Apr 2007 13:46:04 -0400
In-Reply-To: <p737iswqjq4.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I changed the title to be more accurate, and culled the distribution to 
individuals and netdev

The mention of trying to turn-off CKO and see if the data corruption 
goes away leads me to ask a possibly "delicate" question:

   Should "Linux" only enable CKO on those NICs certified to have
   ECC/parity throughout their _entire_ data path?

rick jones
