From: Stephen Clark <sclark46@earthlink.net>
Subject: secure_tcp_sequence_number
Date: Sat, 25 Apr 2009 21:30:24 -0400
Message-ID: <49F3B930.1050500@earthlink.net>
Reply-To: sclark46@earthlink.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from elasmtp-curtail.atl.sa.earthlink.net ([209.86.89.64]:55868 "EHLO
	elasmtp-curtail.atl.sa.earthlink.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751825AbZDZBa2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2009 21:30:28 -0400
Received: from [208.118.36.249] (helo=joker.seclark.com)
	by elasmtp-curtail.atl.sa.earthlink.net with esmtpsa (TLSv1:AES256-SHA:256)
	(Exim 4.67)
	(envelope-from <sclark46@earthlink.net>)
	id 1LxtCL-0004PK-Bd
	for netdev@vger.kernel.org; Sat, 25 Apr 2009 21:30:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

What should a module use since secure_tcp_sequence_number is no longer exported.
Would secure_tcpv6_sequence_number work Ok?

Thanks,
Steve


