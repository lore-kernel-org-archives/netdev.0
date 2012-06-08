From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: 3.4.1 and 3.5-rc1 Packet lost at 250Mb/s
Date: Fri, 08 Jun 2012 10:58:25 +0200
Message-ID: <ddae4973ddff0015d239dd66551be209@justnet.pl>
Reply-To: <adam.niescierowicz@justnet.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
To: Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host-91.230.163.37.ltv.pl ([91.230.163.37]:59042 "EHLO
	mail.justnet.pl" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S934049Ab2FHJUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jun 2012 05:20:32 -0400
Received: from [91.230.163.37] (helo=mail.justnet.pl)
	by service with esmtpa (Exim 4.72)
	(envelope-from <adam.niescierowicz@justnet.pl>)
	id 1Scv1V-00025M-H2
	for netdev@vger.kernel.org; Fri, 08 Jun 2012 10:58:25 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

recently we changed on the router kernel from 2.6.38.1 to 3.4.1 and 
noticed
30% packet loss when traffic increases up to 250MB / s.

Similar is for kernel 3.5-rc1

Here a link to ifstat http://wklej.org/id/767577/

Regards
