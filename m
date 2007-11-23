From: Laszlo Attila Toth <panther@balabit.hu>
Subject: cassini driver hw checksum errors with vlans
Date: Fri, 23 Nov 2007 11:40:01 +0100
Message-ID: <4746AE01.50409@balabit.hu>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:46428 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753942AbXKWKkJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 05:40:09 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 20A5AC13DB
	for <netdev@vger.kernel.org>; Fri, 23 Nov 2007 11:40:06 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

When we use cassini driver without VLANs, it works as expected but when 
about 100 VLANs are configured on this interface, the hardware checksum 
fails.

What is its reason or how can we debug it?

-- 
Attila
