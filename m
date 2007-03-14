From: "lee nookx" <lnookx@googlemail.com>
Subject: kernel routing tables
Date: Wed, 14 Mar 2007 15:23:23 +0000
Message-ID: <40d14a940703140823s81d98d9y87e634bc8c31d072@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.186]:16709 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752756AbXCNPX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 11:23:27 -0400
Received: by nf-out-0910.google.com with SMTP id o25so263237nfa
        for <netdev@vger.kernel.org>; Wed, 14 Mar 2007 08:23:25 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

I am playing with AODV as a routing protocol, and I am having some
trouble getting it to work. I am using the kernel AODV implementation,
which works fine on 2.4.x machines.

I am now trying to get it to run on 2.6 kernels.

One of the problems I am having is that I am getting the error:

WARNING: "ip_rt_ioctl" [/home/lnookx/kernel-aodv/aodv.ko] undefined!


This function seems to allow me to add or delete the routing entries
into the kernels routing table.

Have they been deprecated on recent kernels?


Can anyone offer any help or suggestions?


--lee


--
