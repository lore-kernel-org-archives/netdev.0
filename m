From: Jakub Kicinski <moorray3@wp.pl>
Subject: [PATCHv2 0/3] gianfar: filer changes
Date: Wed, 12 Aug 2015 02:41:54 +0200
Message-ID: <1439340117-25314-1-git-send-email-moorray3@wp.pl>
References: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Cc: netdev@vger.kernel.org, Jakub Kicinski <kubakici@wp.pl>
To: "David S. Miller" <davem@davemloft.net>,
	Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:35421 "EHLO mx4.wp.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932485AbbHLAmE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Aug 2015 20:42:04 -0400
In-Reply-To: <1439237540-11302-1-git-send-email-moorray3@wp.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <kubakici@wp.pl>

Hi,

respinning with examples as requested.

Jakub Kicinski (3):
  gianfar: correct filer table writing
  gianfar: correct list membership accounting
  gianfar: remove faulty filer optimizer

 drivers/net/ethernet/freescale/gianfar_ethtool.c | 345 +----------------------
 1 file changed, 4 insertions(+), 341 deletions(-)

-- 
2.1.0
