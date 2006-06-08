From: Jan-Bernd Themann <ossthema@de.ibm.com>
Subject: EHEA: Is there a size limit below 80K for patches?
Date: Thu, 08 Jun 2006 12:26:44 +0200
Message-ID: <4487FB64.1070307@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: meder@de.ibm.com, raisch@de.ibm.com, schickhj@de.ibm.com,
	themann@de.ibm.com, tklein <osstklei@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.uk.ibm.com ([195.212.29.135]:26013 "EHLO
	mtagate2.uk.ibm.com") by vger.kernel.org with ESMTP id S964816AbWFHKzX
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Jun 2006 06:55:23 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate2.uk.ibm.com (8.13.6/8.13.6) with ESMTP id k58AtMA3055076
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 10:55:22 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k58AuXVc092676
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 11:56:33 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k58AtLLU016932
	for <netdev@vger.kernel.org>; Thu, 8 Jun 2006 11:55:22 +0100
To: netdev <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

we tried two times to send a patch set. In both cases the second (largest) patch
got lost. The first one was a bit above 100k, the second one we tried was like 75K.

Any idea what might be the problem?

Thanks,
Jan-Bernd Themann
