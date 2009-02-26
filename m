From: Santwona.Behera@Sun.COM
Subject: Question about IP-in-IP tunneling
Date: Thu, 26 Feb 2009 13:07:02 -0800
Message-ID: <49A70476.8050300@Sun.COM>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:39868 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752693AbZBZVHc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 16:07:32 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1QL7SkL011153
	for <netdev@vger.kernel.org>; Thu, 26 Feb 2009 13:07:28 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KFO00800YBHAT00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Thu,
 26 Feb 2009 13:07:28 -0800 (PST)
Received: from [129.145.154.102] ([unknown] [129.145.154.102])
 by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 with ESMTPSA id <0KFO007JYYNQPF00@fe-sfbay-10.sun.com> for
 netdev@vger.kernel.org; Thu, 26 Feb 2009 13:07:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A question for the IP tunneling experts:

For IP-in-IP tunneling, what are the cases when IPROTO_IPIP (4) is used 
in the protocol field of the outer IP header and the cases when 
IPPROTO_IPV6 (41) is used instead?

thanks,
--santwona
