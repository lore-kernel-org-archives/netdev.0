From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Stability of various TCP protocols [CUBIC, BIC, HTCP, HSTCP, STCP]
Date: Thu, 28 Sep 2006 13:00:35 -0400
Message-ID: <00f901c6e31f$9e04e4d0$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ks_c_5601-1987";
	reply-type=original
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni05mr.unity.ncsu.edu ([152.1.224.164]:52628 "EHLO
	uni05mr.unity.ncsu.edu") by vger.kernel.org with ESMTP
	id S1751935AbWI1RAp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:00:45 -0400
Received: from ncsu2cc0c3fa00 (bakdu.csc.ncsu.edu [152.14.88.74])
	by uni05mr.unity.ncsu.edu (8.13.7/8.13.4/Nv5.2006.0214) with SMTP id k8SH0iRb019573
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 13:00:44 -0400 (EDT)
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,
I'd like to report on a measurement study regarding the stability of various 
TCP variant protocols. Although we can find quite a bit of work on fairness 
and convergence of protocols (including some theoretical studies on the 
topic as well), there is relatively little work on measuring the stability 
of protocols and its impact on protocol performance and overall health of 
the networks (e.g., the overall queue fluctions and link utilization). We 
have measured the degree of rate oscillation and fluctuation of protocols to 
have some understanding of protocol stability. We would like to share our 
results with you to get some feedback from the community.

We have some theoretical results and also experimental results. Here is the 
link to the experimental results. You can find links to all of our 
experimental data that include results from several hundred experiments.

http://netsrv.csc.ncsu.edu/convex-ordering/

If you need our report on theoretical results,  we can e-mail you the 
report.
Injong Rhee 

