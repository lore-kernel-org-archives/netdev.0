From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Network namespace ported to 2.6.21-mm2
Date: Tue, 19 Jun 2007 15:12:45 +0200
Message-ID: <4677D64D.1020604@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>
To: Linux Containers <containers@lists.osdl.org>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:53806 "EHLO
	mtagate1.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756608AbXFSNNq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jun 2007 09:13:46 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id l5JDDiqP173590
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 13:13:44 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5JDDhY81491188
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 14:13:43 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5JDDghi011816
	for <netdev@vger.kernel.org>; Tue, 19 Jun 2007 14:13:43 +0100
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

The network namespace patchset has been ported to 2.6.21-mm2.

They are still some issues but we are on it, for this reason the 
patchset is named netns1-beta1.

The patchset can be found here :

http://lxc.sourceforge.net/patches/2.6.21/2.6.21-mm2-netns1-beta1/

Documentation can be found here :

http://lxc.sourceforge.net/network.php

Any suggestions or comments are welcome.

Thanks.

    -- Daniel

