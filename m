From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: iproute2 / htb / question
Date: Wed, 21 Jan 2009 16:33:16 +0200
Message-ID: <200901211633.16638.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:42947 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753842AbZAUOdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2009 09:33:20 -0500
Received: from [195.69.208.252] (unknown [195.69.208.252])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	(Authenticated sender: denys@visp.net.lb)
	by hosting.visp.net.lb (Postfix) with ESMTPSA id B1FF11A4B40
	for <netdev@vger.kernel.org>; Wed, 21 Jan 2009 16:33:12 +0200 (EET)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need to ask few questions, thats maybe better to ask somewhere like IRC. But 
mail is ok, if i can get answers...

Because i am not understanding well, how HTB works.
For example iproute2 over netlink sending various parameters. For me 
interesting now burst/cburst since they are seems incorrect.

It is some "tokens" that used to refill bucket each piece of time (related 
with get_hz and rate?) 
Is there any place i can read about this?
