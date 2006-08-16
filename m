From: "Beschorner Daniel" <Daniel.Beschorner@facton.com>
Subject: skge crashes
Date: Wed, 16 Aug 2006 19:47:08 +0200
Message-ID: <664E3671B2B6DC439E0C9FFCF8E40CA205F500@exchange.I-BNEX>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from loewe.unit-netz.de ([212.202.148.42]:6099 "EHLO
	loewe.unit-netz.de") by vger.kernel.org with ESMTP id S1751229AbWHPRr3 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Aug 2006 13:47:29 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>,
	"Krzysztof Oledzki" <olel@ans.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen,

the reproducible crashes with all skge versions (where sk98lin works
fine) on my box are SMP related.
I booted with maxcpus=1 and the box survived my usual crash test, I will
keep an eye.

Daniel
