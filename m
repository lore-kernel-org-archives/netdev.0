From: "anandvelu thulasiram" <anand.vt@gmail.com>
Subject: TSO performance wrt 2.614
Date: Fri, 9 Mar 2007 12:07:20 +0530
Message-ID: <bb8a0130703082237q2ac1025haf3cd9f590c47aa3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:17239 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993007AbXCIGhX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Mar 2007 01:37:23 -0500
Received: by nf-out-0910.google.com with SMTP id o25so946370nfa
        for <netdev@vger.kernel.org>; Thu, 08 Mar 2007 22:37:22 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
               I'm working on TCP segmentation Offload and I'm using
Linux -2.6.14 kernel for this. I'm getting about a 6x increase in
sending by turning off TCP segmentation offload. But When I turn on
the TSO my performance is getting degraded.  But when I switched back
to Linux
2.6.9 kernel I'm getting 16Mbps more when TSO is enabled.

Is there any TSO patch for linux-2.6.14.


Thanks In Advance
Anand
