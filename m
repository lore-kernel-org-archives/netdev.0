From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH net-next 2/2] tools: bpf: add bpftool
Date: Thu, 28 Sep 2017 06:59:12 -0700
Message-ID: <20170928065912.00a9b6a1@cakuba>
References: <20170926153522.31500-1-jakub.kicinski@netronome.com>
        <20170926153522.31500-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, hannes@stressinduktion.org,
        dsahern@gmail.com, oss-drivers@netronome.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.12]:7301 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753029AbdI1N73 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 28 Sep 2017 09:59:29 -0400
Received: from unknown (HELO cakuba) (kubakici@wp.pl@[75.53.12.129])
          (envelope-sender <kubakici@wp.pl>)
          by smtp.wp.pl (WP-SMTPD) with ECDHE-RSA-AES256-GCM-SHA384 encrypted SMTP
          for <netdev@vger.kernel.org>; 28 Sep 2017 15:59:26 +0200
In-Reply-To: <20170926153522.31500-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Sep 2017 08:35:22 -0700, Jakub Kicinski wrote:
> Add a simple tool for querying and updating BPF objects on the system.
> 
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
> Reviewed-by: Simon Horman <simon.horman@netronome.com>

Dave, I got some late review nitpicks internally which I think are
worth addressing.  Would you mind dropping this series?  I will post v2
with the cleanups and README included.
