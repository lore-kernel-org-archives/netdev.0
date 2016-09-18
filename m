From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Sun, 18 Sep 2016 19:25:14 +0200
Message-ID: <20160918192514.510d4702@redhat.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
        <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
        <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
        <20160912230745.GA24171@ast-mbp.thefacebook.com>
        <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        bblanco@plumgrid.com, jeffrey.t.kirsher@intel.com,
        davem@davemloft.net, xiyou.wangcong@gmail.com,
        intel-wired-lan@lists.osuosl.org, u9012063@gmail.com,
        netdev@vger.kernel.org, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56860 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751581AbcIRRZV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Sep 2016 13:25:21 -0400
In-Reply-To: <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Sep 2016 16:46:08 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> This XDP_TX thing was one of the XDP marketing stuff, but there is
> absolutely no documentation on it, warning users about possible
> limitations/outcomes.

I will take care of documentation for the XDP project.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
