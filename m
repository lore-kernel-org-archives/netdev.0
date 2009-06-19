From: Joel Becker <Joel.Becker@oracle.com>
Subject: TCP Persist Timer DoS
Date: Fri, 19 Jun 2009 15:31:06 -0700
Message-ID: <20090619223106.GJ29140@mail.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:22412 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758714AbZFSWbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jun 2009 18:31:37 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by acsinet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n5JMWd6t013701
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 22:32:40 GMT
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by acsinet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n5JC9qX2023899
	for <netdev@vger.kernel.org>; Fri, 19 Jun 2009 22:32:58 GMT
Received: from jlbec by ca-server1.us.oracle.com with local (Exim 4.69)
	(envelope-from <joel.becker@oracle.com>)
	id 1MHmbw-0005DJ-Kt
	for netdev@vger.kernel.org; Fri, 19 Jun 2009 15:31:04 -0700
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey Netfolk,
	I have to assume you've seen
http://www.phrack.org/issues.html?issue=66&id=9&mode=txt.  Does anyone
have a plan or opinion on the DoS?  A way to mitigate it, a -EDONTCARE
opinion, anything?

Joel

-- 

"For every complex problem there exists a solution that is brief,
     concise, and totally wrong."
                                        -Unknown

Joel Becker
Principal Software Developer
Oracle
E-mail: joel.becker@oracle.com
Phone: (650) 506-8127
