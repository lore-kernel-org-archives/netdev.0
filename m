From: Richard =?ISO-8859-1?Q?R=F6jfors?=
	<richard.rojfors@pelagicore.com>
Subject: [PATCH 0/2] ks8842: Support for passing flags via platform data
 and 100 Mbps support
Date: Sat, 24 Jul 2010 22:25:08 +0200
Message-ID: <1280003108.28285.279.camel@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-h32.telenor.se ([213.150.131.5]:38354 "EHLO
	smtprelay-h32.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274Ab0GXUZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 16:25:13 -0400
Received: from ipb2.telenor.se (ipb2.telenor.se [195.54.127.165])
	by smtprelay-h32.telenor.se (Postfix) with ESMTP id 6383BE9587
	for <netdev@vger.kernel.org>; Sat, 24 Jul 2010 22:25:10 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To follow are two patches
 * Introduce a flags field in the platform data.
 * removes flow control and advertise 100Mbps

