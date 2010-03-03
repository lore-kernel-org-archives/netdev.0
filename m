From: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>
Subject: TCP Appropriate Byte Counting per default off
Date: Wed, 03 Mar 2010 09:21:44 +0100
Message-ID: <A7D42088-84DC-4991-A8AD-E4000B2974DA@nets.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	"ilpo.jarvinen@helsinki.fi J?rvinen" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:61193 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751200Ab0CCIVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Mar 2010 03:21:46 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0KYP00AQ05WAEK60@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 03 Mar 2010 09:21:46 +0100 (CET)
Received: from miami.nets.rwth-aachen.de ([unknown] [137.226.12.180])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0KYP00CLN5WAQP10@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 03 Mar 2010 09:21:46 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, hi Ilpo,

I wonder why ABC is off per default? What are the reasons?
Should we turn it on per default?

>From algorithmic point of view I see no flaws just
benefits.

With RFC5681 ABC is recommended.
OSX uses ABC per default.

Alex

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22220
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//

