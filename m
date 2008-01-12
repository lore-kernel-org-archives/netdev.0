From: David Miller <davem@davemloft.net>
Subject: net-2.6.25 rebased...
Date: Sat, 12 Jan 2008 03:31:44 -0800 (PST)
Message-ID: <20080112.033144.158640704.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36299
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752906AbYALLbp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 06:31:45 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id C84A3C8C2B4
	for <netdev@vger.kernel.org>; Sat, 12 Jan 2008 03:31:44 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I fixed up some utf-8 encoding issues in changelog messages,
got rid of superfluous patches ("X" then "revert X" cases)
and combined bug fixes into the patches which introduced
them.

We are just over 700 patches, keep them coming :-)
