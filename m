From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 0/8] netpoll: A Halloween horror mystery
Date: Thu, 26 Oct 2006 15:46:48 -0700
Message-ID: <20061026225535.443288276@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12474 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1945979AbWJZXAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 19:00:00 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

It was dull and cloudy day in Portland when Steve first
went hunting for suspend bugs in the sky2 driver. The hunt
was motivated by a certain mini owned by penguin, but he
could never get the license number. Anyway, he stumbled
down some blind alleys and met the:

	NETPOLL BEAST

It wasn't that beast was ugly, like some of the other
things he had seen. It was just an untidy mess, the kind
of thing you didn't want to bring home to mother, instead
he would have rather booted over the fence to the Viro
shredder.  But since he was in the neighborhood, he
got out his keyboard and went to work.

--

