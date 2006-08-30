From: Brian Braunstein <brian@bristyle.com>
Subject: PATCH: br_stp.c:271: ignoring BPDUs if cost goes up
Date: Wed, 30 Aug 2006 11:04:36 -0700
Message-ID: <44F5D334.7050205@bristyle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, rajesh_mish@yahoo.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox8.ucsd.edu ([132.239.1.60]:48906 "EHLO mailbox8.ucsd.edu")
	by vger.kernel.org with ESMTP id S1751279AbWH3S5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2006 14:57:22 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

PATCH
problem at: br_stp.c:271
problem: ignoring BPDUs if cost goes up

i was refered to email these addresses by the bridging code author.

please see the full problem description and patch at:
http://mesh.calit2.net/calmesh/one/linux_kernel_modifications/bridge_ignoring_bpdus/

if you would like to have it attached or inline with the email instead 
let me know.

