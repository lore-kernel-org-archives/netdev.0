From: Hariprasad S <hariprasad@chelsio.com>
Subject: query: Can ethtool be used to print Expansion ROM version of the
 adapter?
Date: Wed, 28 Jan 2015 02:18:33 +0000
Message-ID: <26E3F92EC670BD429DB5CB319D773C13C7FE19@nice.asicdesigners.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ben@decadent.org.uk" <ben@decadent.org.uk>,
	"davem@davemloft.net" <davem@davemloft.net>,
	Nirranjan Kirubaharan <nirranjan@chelsio.com>,
	"Casey Leedom" <leedom@chelsio.com>,
	Kumar A S <kumaras@chelsio.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:13708 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760645AbbA1CSu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2015 21:18:50 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi,

For printing the Expansion ROM version of the adapter, we were thinking if ethtool
could be used for it ?
There are fields in ethtool_drvinfo to display fw_version and driver_version. Also,
there are two reserved fields present. Are these two reserved fields already in use ?
Could anyone of the reserved field be used to print the custom adapter info like
Expansion ROM version ?

Thanks,
Hariprasad Shenai