From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [ANNOUNCE] bridge-utils 1.4
Date: Tue, 8 Jan 2008 08:56:07 -0800
Message-ID: <20080108085607.37ab168f@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: bridge@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50032 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758076AbYAHQ6I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 11:58:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minor update to bridge-utils. Mostly fixing bugs in usage of sysfs.

Release tarball:
  http://downloads.sourceforge.net/bridge/bridge-utils-1.4.tar.gz

Alon Bar-Lev (1):
      Allow bridge-utils to run when no TCP/IP is available

Denys Vlasenko (1):
      fix use of sysfs (affects 32/64 bit compat)

Jeremy Jackson (1):
      Fix parsing of port_id's (hex).

Stephen Hemminger (3):
      Add ignore for generated files.
      Update gitignore
      Use linux/if.h rather than net/if.h


-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>
