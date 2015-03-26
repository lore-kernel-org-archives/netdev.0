From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 0/6] mvneta: SGMII-based in-band link status signaling
Date: Thu, 26 Mar 2015 18:56:33 +0300
Message-ID: <55142C31.5050504@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Rami Rosen <rosenr@marvell.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fallback7.mail.ru ([94.100.181.128]:51955 "EHLO
	fallback7.mail.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbbCZQQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2015 12:16:07 -0400
Received: from smtp15.mail.ru (smtp15.mail.ru [94.100.176.133])
	by fallback7.mail.ru (mPOP.Fallback_MX) with ESMTP id 6CE94135BAD14
	for <netdev@vger.kernel.org>; Thu, 26 Mar 2015 18:56:40 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

The following patches are needed when mvneta is used
in SGMII mode without MDIO.
