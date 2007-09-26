From: Dave Jones <davej@redhat.com>
Subject: e100 problems in .23rc8 ?
Date: Wed, 26 Sep 2007 11:04:47 -0400
Message-ID: <20070926150447.GA3761@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37910 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbXIZPEt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Sep 2007 11:04:49 -0400
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.13.1/8.13.1) with ESMTP id l8QF4mFr029741
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 11:04:48 -0400
Received: from gelk.kernelslacker.org (vpn-14-1.rdu.redhat.com [10.11.14.1])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id l8QF4mkt022855
	for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 11:04:48 -0400
Received: from gelk.kernelslacker.org (localhost.localdomain [127.0.0.1])
	by gelk.kernelslacker.org (8.14.1/8.13.8) with ESMTP id l8QF4lEp021940
	for <netdev@vger.kernel.org>; Wed, 26 Sep 2007 11:04:47 -0400
Received: (from davej@localhost)
	by gelk.kernelslacker.org (8.14.1/8.14.1/Submit) id l8QF4lmN021939
	for netdev@vger.kernel.org; Wed, 26 Sep 2007 11:04:47 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Last night, I hit this bug during boot up..
http://www.codemonkey.org.uk/junk/e100-2.jpg

This morning, I got a mail from a Fedora user of the same
.23-rc8 based kernel that has seen a different trace
also implicating e100..

http://www.codemonkey.org.uk/junk/e100.jpg

It may be that the two problems are unrelated, and it's
just coincidence that both reports happen to be on an e100,
but the timing is odd.  Have there been other reports
of similar problems recently ?

	Dave

-- 
http://www.codemonkey.org.uk
