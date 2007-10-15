From: Moni Shoua <monisonlists@gmail.com>
Subject: [PATCH V7 0/8] net/bonding: ADD IPoIB support for the bonding driver
Date: Mon, 15 Oct 2007 18:00:55 +0200
Message-ID: <47138EB7.40703@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, general@lists.openfabrics.org
To: jgarzik@pobox.com, fubar@us.ibm.com, rdreier@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:39125 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753775AbXJOQBH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Oct 2007 12:01:07 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is the 7th version of this patch series. See link to V6 below.

Changes from the previous version
---------------------------------

* Some patches required modifications to remove offsets so they can be applied with git-apply
* Patch #3 was first modified by Jay and later by me to make it work with header_ops
* patch #8 was changed to fix the problem that caused 'ifconfig down' to stuck (dev_close was called twice)

Jay,
I removed the Acked-by lines from patches 3 & 8. Can you please add them back after you approve?

thanks
	MoniS

Link to V6: 
	http://lists.openfabrics.org/pipermail/general/2007-September/041139.html


