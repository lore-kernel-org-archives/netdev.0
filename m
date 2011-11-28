From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: RE: [net-next v2 0/9] bnx2x: Link changes
Date: Mon, 28 Nov 2011 01:09:04 -0800
Message-ID: <41FDA5AFCC66094F83A3D9545495A2A41522976131@SJEXCHCCR01.corp.ad.broadcom.com>
References: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2608 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109Ab1K1JJM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 04:09:12 -0500
In-Reply-To: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 This is V2 of series of patches for bnx2x driver.

 The changes from initial commit:
1. Adding new patch9 - Change value comparison order from "val == X" to "X == val".
2. Patch2 - Fix coding convention as #1.
3. Patch4 - Fix indentation.
4. Patch5 - Fix indentation.
5. Patch6 - Fix indentation.
6. Patch7 - Fix indentation.

-----Original Message-----
From: Yaniv Rosner [mailto:yanivr@broadcom.com] 
Sent: Monday, November 28, 2011 12:50 PM
To: David Miller
Cc: netdev; Yaniv Rosner
Subject: [net-next v2 0/9] bnx2x: Link changes

Hi Dave,
The following patch series describe some link changes.
Please consider applying it to net-next.

Thanks,
Yaniv
