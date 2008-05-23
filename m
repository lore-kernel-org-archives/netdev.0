From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: Version numbering
Date: Fri, 23 May 2008 12:32:10 -0700
Message-ID: <20080523193210.GB26044@localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	"Benjamin Li" <benli@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3300 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754589AbYEWT2n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 15:28:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David.  I'm sitting on a small patchset of bugfixes destined for the
net-2.6 tree, but I'm a little confused about how I should handle the
version numbering.

Right now, the net-2.6 tg3 driver is at version 3.92.  The net-next-2.6
tree has 5785 support added and has a version of 3.93.  If we apply
these patches to the net-2.6 driver, we will want to increase the
version number.  How would you prefer we handle this?


