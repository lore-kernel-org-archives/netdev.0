From: "Injong Rhee" <rhee@eos.ncsu.edu>
Subject: Heads-up: updates on slow start
Date: Fri, 29 Feb 2008 09:00:59 -0500
Message-ID: <00f401c87adb$8375efb0$4a580e98@ncsu2cc0c3fa00>
Mime-Version: 1.0
Content-Type: text/plain;
	format=flowed;
	charset="ks_c_5601-1987";
	reply-type=original
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from uni10mr.unity.ncsu.edu ([152.1.1.170]:64742 "EHLO
	uni10mr.unity.ncsu.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412AbYB2OBK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Feb 2008 09:01:10 -0500
Received: from ncsu2cc0c3fa00 (bakdu.csc.ncsu.edu [152.14.88.74])
	by uni10mr.unity.ncsu.edu (8.13.7/8.13.8/Nv5.2007.0604) with SMTP id m1TE18QP004061
	for <netdev@vger.kernel.org>; Fri, 29 Feb 2008 09:01:08 -0500 (EST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have been working on slow start for a while.  We have now a workable 
solution. You find more information about it from the following paper 
http://netsrv.csc.ncsu.edu/export/pfldnet08_slowstart.pdf. We will publish 
the slow start patch after we run some more tests over the Internet and 
gather some comments from the community to confirm its benefits.

