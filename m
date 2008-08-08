From: jamal <hadi@cyberus.ca>
Subject: [PATCH]ip: Allow for easier debug of buggy devices that dont send
	their names
Date: Fri, 08 Aug 2008 10:00:48 -0400
Message-ID: <1218204048.4688.62.camel@localhost>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:15654 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751852AbYHHOBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Aug 2008 10:01:33 -0400
Received: by yx-out-2324.google.com with SMTP id 8so241167yxm.1
        for <netdev@vger.kernel.org>; Fri, 08 Aug 2008 07:01:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

wireless drivers using wext is a prime example if you need a test case.

cheers,
jamal

