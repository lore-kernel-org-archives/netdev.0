From: Albert Lee <albertcc@tw.ibm.com>
Subject: Is the qla3xxx driver in the mainline?
Date: Wed, 26 Jul 2006 11:45:10 +0800
Message-ID: <44C6E546.8030502@tw.ibm.com>
Reply-To: albertl@mail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, Doug Maxey <dwm@enoyolf.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:52373 "EHLO
	e31.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030372AbWGZDp7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jul 2006 23:45:59 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k6Q3jw00012600
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <netdev@vger.kernel.org>; Tue, 25 Jul 2006 23:45:58 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k6Q3jvEH169830
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 25 Jul 2006 21:45:57 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k6Q3jvqS031392
	for <netdev@vger.kernel.org>; Tue, 25 Jul 2006 21:45:57 -0600
To: Ron Mercer <ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ron,

The qla3xxx driver is in the -mm tree.

For the mainline inclusion, Jeff seems ready to accept the driver:
http://marc.theaimsgroup.com/?l=linux-netdev&m=115334172810775&w=2

Just wondering if the qla3xxx driver is in the mainline yet?

(I am curious to have some performance comparison of
qla3xxx + open iscsi v.s. qla4xxx + on board TOE/iscsi.)

--
albert

