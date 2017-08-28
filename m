From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] selftests/bpf: check the instruction dumps
 are populated
Date: Mon, 28 Aug 2017 15:35:31 -0700 (PDT)
Message-ID: <20170828.153531.439222198348214203.davem@davemloft.net>
References: <20170825213957.4768-1-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, kafai@fb.com,
        oss-drivers@netronome.com
To: jakub.kicinski@netronome.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49956 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdH1Wfc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:35:32 -0400
In-Reply-To: <20170825213957.4768-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Date: Fri, 25 Aug 2017 14:39:57 -0700

> Add a basic test for checking whether kernel is populating
> the jited and xlated BPF images.  It was used to confirm
> the behaviour change from commit d777b2ddbecf ("bpf: don't 
> zero out the info struct in bpf_obj_get_info_by_fd()"),
> which made bpf_obj_get_info_by_fd() usable for retrieving
> the image dumps.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Applied.
