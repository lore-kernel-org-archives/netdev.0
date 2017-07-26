From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] bpf: install libbpf headers on 'make
 install'
Date: Wed, 26 Jul 2017 13:43:45 -0700 (PDT)
Message-ID: <20170726.134345.340606252498772041.davem@davemloft.net>
References: <20170724212236.21903-1-jakub.kicinski@netronome.com>
        <20170725181711.21236-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        oss-drivers@netronome.com, alexei.starovoitov@gmail.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751325AbdGZUnq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 16:43:46 -0400
In-Reply-To: <20170725181711.21236-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Tue, 25 Jul 2017 11:17:11 -0700

> Add a new target to install the bpf.h header to $(prefix)/include/bpf/ 
> directory.  This is necessary to build standalone applications using 
> libbpf, without the need to clone the kernel sources and point to them.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied, thank you.
