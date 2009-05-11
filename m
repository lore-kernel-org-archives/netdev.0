From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [RFC 0/5] bridge - introduce via_phys_dev feature
Date: Mon, 11 May 2009 15:46:39 +0400
Message-ID: <20090511114639.440944109@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, xemul@openvz.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.225]:31090 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755482AbZEKMxz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 08:53:55 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2140700rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 05:53:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

here is RFC for new via_phys_dev bridge feature.
In short -- it allows to use some bridge port as
bridge itself with already configured routing table.

More details with example you may found in patches.

Please review. Any (including _complains_) comments are
highly appreciated!

The series is on top of current -net-next-2.6

	| commit ed9b58bc443a1210b5be1ded6421b17e015bf985
	| Author Richard Genoud <richard.genoud@gmail.com>
	| Date Sat May 9 06:59:16 2009 +0000

Cyrill
