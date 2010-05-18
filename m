From: Jon Zhou <Jon.Zhou@jdsu.com>
Subject: has virtual nic?
Date: Mon, 17 May 2010 18:25:55 -0700
Message-ID: <4A6A2125329CFD4D8CC40C9E8ABCAB9F2497EFBD6A@MILEXCH2.ds.jdsu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og109.obsmtp.com ([64.18.2.171]:42404 "HELO
	exprod7og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754162Ab0ERB0b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 21:26:31 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi net guru:

kernel has multi virtual nic for those 10Gb multiqueue nic ?
 
if all user space applications process packets via a unique access point(I mean,the nic device,socket system call,mmap)
will it get performance bottleneck?
