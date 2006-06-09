From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: [PATCH] ehea: IBM eHEA Ethernet Device Driver - first full release
Date: Fri, 09 Jun 2006 15:02:15 +0200
Message-ID: <44897157.3010600@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, schickhj@de.ibm.com,
	themann@de.ibm.com, tklein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:43606 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP id S965255AbWFINbE
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Jun 2006 09:31:04 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k59DV3Ja140724
	for <netdev@vger.kernel.org>; Fri, 9 Jun 2006 13:31:03 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k59DWFfM128926
	for <netdev@vger.kernel.org>; Fri, 9 Jun 2006 14:32:15 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k59DV3RR000432
	for <netdev@vger.kernel.org>; Fri, 9 Jun 2006 14:31:03 +0100
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

here is the URL for our device driver. It is a tarball containing
a patch set for kernel 2.6.17-rc6. This version should compile
without warning.

http://prdownloads.sourceforge.net/ibmehcad/ehea_EHEA_0005_2.6.17-rc6.tgz?download

Signed-off-by: Jan-Bernd Themann <themann@de.ibm.com>
Changelog-by:  Jan-Bernd Themann <themann@de.ibm.com>

Differences to patch set http://www.spinics.net/lists/netdev/msg05889.html

Changelog:

- Added Kconfig and Makefile patch in drivers/net
- Changed tarball to patches instead of .c files

Jan-Bernd


 > Patches and new drivers should always go to the mailing
 > list...... except for the case where they are too big to
 > be posted to the mailing list.  For that special case,
 > a URL to a patch should be posted.
 >
 >    Jeff
