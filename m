From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 00/06] bnx2x: net-next patch series
Date: Wed, 27 Mar 2013 13:05:13 +0200
Message-ID: <1364382319-24952-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2697 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752772Ab3C0MKW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 08:10:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This patch series mostly contains patches correcting the
behaviour of VFs - preventing races, correcting VFs' statistics,
etc. 

It also enhances bnx2x's `ethtool -m' command.

Please consider applying these patches to 'net-next'.

Thanks,
Yuval Mintz
