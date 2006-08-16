From: Andy Furniss <lists@andyfurniss.entadsl.com>
Subject: Can't turn off CONFIG_NET_ESTIMATOR on 2.6.17.7
Date: Wed, 16 Aug 2006 16:21:37 +0100
Message-ID: <44E33801.3050203@andyfurniss.entadsl.com>
Reply-To: lists@andyfurniss.entadsl.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.ukfsn.org ([217.158.120.143]:59613 "EHLO mail.ukfsn.org")
	by vger.kernel.org with ESMTP id S932066AbWHPPUV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 11:20:21 -0400
Received: from [192.168.0.3] (unknown [87.127.23.106])
	by mail.ukfsn.org (Postfix) with ESMTP id 10F60E708C
	for <netdev@vger.kernel.org>; Wed, 16 Aug 2006 16:18:35 +0100 (BST)
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



I Recently built a 2.6.17.7 and wanted to turn off CONFIG_NET_ESTIMATOR 
but can't using menuconfig.

Is it on by default now, or is it a config issue?

I wanted it off to play with chains of policers and unless I 
misunderstand it uses Hz, and is inaccurate when Hz=250 with its' 
minimum time of 1/4 sec - which is too high for what I wanted anyway.

Andy.

