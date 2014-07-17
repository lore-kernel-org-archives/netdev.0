From: Sharat Masetty <sharat04@gmail.com>
Subject: Possible features for hardware offload
Date: Wed, 16 Jul 2014 18:33:07 -0600
Message-ID: <CAJzFV37Qs7ODUCK85w7-EPBzqgkWheD-skrQ49Yifc4zPhUuyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f43.google.com ([74.125.82.43]:46295 "EHLO
	mail-wg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbaGQAdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 20:33:09 -0400
Received: by mail-wg0-f43.google.com with SMTP id l18so1652365wgh.26
        for <netdev@vger.kernel.org>; Wed, 16 Jul 2014 17:33:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apart from Checksum offload, I am trying to identify what other parts
of the network stack can be potentially offloaded to hardware with the
goal of reducing the overall CPU utilization for very high data rates.
I am looking for high level data points which I can further research
into.

Few Additional questions
Is there documentation available for GRO feature, that can help me
understand the architecture and also the kernel implementation?
Looking for pointers to start. Same question for TCP segmentation
offload feature.
Is there a kernel supported way of offloading netfilter filtering to hardware?

Regards,
Sharat
