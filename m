From: "John Reynolds" <JReynolds@datacore.uk.com>
Subject: Hi,
Date: Sat, 26 Oct 2013 05:15:24 +0100
Message-ID: <526B4FEC020000B100033DCD@mailhost1.datacore.uk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from reynolds167.plus.com ([84.92.34.172]:47540 "EHLO
	mailhost1.datacore.uk.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893Ab3JZEP3 convert rfc822-to-8bit (ORCPT
	<rfc822;groupwise-netdev@vger.kernel.org:1:1>);
	Sat, 26 Oct 2013 00:15:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
Is there a userspace API that can be used to determine if a network interface is a 802.1Q interface, and what its vlan id and parent interface is. it appears that SOICGIFPFLAGS is not supported and netdev_priv() is only available to drivers, or do I have to resort to parsing the /proc/net/* files ?
 
regards
