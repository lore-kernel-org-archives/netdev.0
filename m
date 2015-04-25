From: Mindiell <mindiell@mindiell.net>
Subject: Question about raw_socket
Date: Sat, 25 Apr 2015 21:22:34 +0200
Message-ID: <553BE97A.3050904@mindiell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kepler.mindiell.net ([88.163.130.11]:53592 "EHLO
	kepler.mindiell.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbbDYT2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 15:28:21 -0400
Received: from [192.168.0.10] (unknown [192.168.0.254])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: tbouchet)
	by kepler.mindiell.net (Postfix) with ESMTPSA id B9F1E9C01DB
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 21:24:20 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I'm using recvfrom with a raw_socket and I was wondering if the frame
"captured" was totally blocked or if it will be passed to the rest of
the other processes or daemons or whatever ?

I mean: If I'm "sniffing" traffic, will my network be blocked or not ?

Thx,
Mindiell
