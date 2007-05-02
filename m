From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 0/4]: s390: network driver fixes and feature
Date: Wed, 2 May 2007 15:13:32 +0200
Message-ID: <20070502131331.GA13217@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	fpavlic@de.ibm.com
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:51182 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993135AbXEBNKw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 09:10:52 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi ,
this is the second version of patches I have sent already two days ago.
I removed the kthread_run patch (3/5) .

Patches 1-3 contain fixes,patch 4 includes some 
kind of a new feature although it is just an adaption 
to the latest OSA hardware specification
and just prints out human readable text on 
specific error return codes.

Please apply them .

Thank you .

Frank
