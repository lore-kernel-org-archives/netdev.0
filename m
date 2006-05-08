From: Stephen Hemminger <shemminger@osdl.org>
Subject: [patch 0/9] sky2 update
Date: Mon, 08 May 2006 15:11:25 -0700
Message-ID: <20060508221125.177816000@localhost.localdomain>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:12989 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751313AbWEHWXy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 18:23:54 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k48MNmtH003743
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:51 -0700
Received: from shell0.pdx.osdl.net (localhost [127.0.0.1])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k48MNmkg023538
	for <netdev@vger.kernel.org>; Mon, 8 May 2006 15:23:48 -0700
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bug fixes for sky2 driver:
 * fix NAPI related race that caused hangs
 * possible fixes for Yukon Ultra PHY support
 * performance improvement of ring management
 * fix race with irq on module removal

--

