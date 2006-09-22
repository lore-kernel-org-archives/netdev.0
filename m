From: Stephen Hemminger <shemminger@osdl.org>
Subject: [ANNOUNCE] bridge-utils 1.2
Date: Fri, 22 Sep 2006 16:24:36 -0700
Message-ID: <20060922162436.21ff5bea@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xensource.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:16552 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964916AbWIVXYu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2006 19:24:50 -0400
To: bridge@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a minor release update to the bridge utilities to fix some
build issues and remove the usage of libsysfs. libsysfs wasn't making the
code easier and it was a pain for other build environments.

Also some error messages and spelling fixes, etc.

Download from:
	http://prdownloads.sourceforge.net/bridge/bridge-utils-1.2.tar.gz?download

-- 
Stephen Hemminger <shemminger@osdl.org>
