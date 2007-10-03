From: Sonny <smaniaol@gmail.com>
Subject: Kernel 2.4 vs 2.6 Traffic Controller Performance
Date: Wed, 3 Oct 2007 08:30:02 +0800
Message-ID: <9dbec86d0710021730g2cfaeb16o7057700b970f7e8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:61435 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbXJCAaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 20:30:14 -0400
Received: by wx-out-0506.google.com with SMTP id h31so3805583wxd
        for <netdev@vger.kernel.org>; Tue, 02 Oct 2007 17:30:13 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello
I hope this is the right place to ask this.Does any know if there is a
substantial difference in the performance of the traffic controller
between kernel 2.4 and 2.6. We tested it using 1 iperf server and use
250 and 500 clients, altering the burst. We use the top command to
check the idle time of our router to see this. The results we got from
the 2.4 kernel shows around 65-70% idle time while the 2.6 shows
60-65% idle time. We tried to use MRTG and we're not getting any
results either. We want to know if we could improve the bandwidth by
upgrading the kernel, else we would have to get a new bandwidth
manager.  Could anyone have the similar test regarding this or suggest
a better way to do this. Thanks in advance.
