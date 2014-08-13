From: FengYu LeiDian <fengyuleidian0615@gmail.com>
Subject: socket option PACKET_VNET_HDR usage
Date: Wed, 13 Aug 2014 20:04:46 +0800
Message-ID: <53EB545E.6010909@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:43864 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750772AbaHMMFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2014 08:05:41 -0400
Received: by mail-pa0-f65.google.com with SMTP id kx10so6893967pab.4
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2014 05:05:41 -0700 (PDT)
Received: from [134.134.139.74] (jfdmzpr05-ext.jf.intel.com. [134.134.139.74])
        by mx.google.com with ESMTPSA id fk13sm2819140pdb.39.2014.08.13.05.05.39
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 13 Aug 2014 05:05:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, All

What's the usage scenario of PACKET_VNET_HDR option?

I noticed the author of its owner tried use it in a qemu patch below:
but it didn't seems to be merged after I quick search current qemu tree.
Is there any other user land application to make use of this option?

https://www.mail-archive.com/kvm@vger.kernel.org/msg27833.html


Thanks
