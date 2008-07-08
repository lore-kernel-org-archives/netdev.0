From: Patrick McHardy <kaber@trash.net>
Subject: [RFC PATCH 03/04]: packet: Store VLAN tag in auxillary data
Date: Tue, 08 Jul 2008 12:16:23 +0200
Message-ID: <48733E77.20808@trash.net>
References: <48733E1B.8010501@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54912 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753855AbYGHKQ0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:16:26 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id BBA72948D9
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2008 12:16:25 +0200 (MEST)
In-Reply-To: <48733E1B.8010501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

