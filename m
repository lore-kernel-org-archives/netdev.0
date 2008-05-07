From: Hannes Hering <hannes.hering@linux.vnet.ibm.com>
Subject: [PATCH 0/3] [2.6.26] ehea: Add DLPAR memory remove support
Date: Wed, 7 May 2008 14:39:06 +0200
Message-ID: <200805071439.06460.hannes.hering@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org, ossrosch@linux.vnet.ibm.com,
	ossthema@de.ibm.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:47269 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751242AbYEGMjI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2008 08:39:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this patchset adds memory remove hotplug support for the ehea driver. 

These patches apply against kernel 2.6.26-rc1.

Regards

Hannes
