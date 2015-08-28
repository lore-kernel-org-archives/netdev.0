From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 1/4] ip_tunnels: convert the mode field of
 ip_tunnel_info to flags
Date: Fri, 28 Aug 2015 09:32:38 -0700
Message-ID: <20150828163237.GA10425@Alexeis-MBP-2.westell.com>
References: <cover.1440771116.git.jbenc@redhat.com>
 <21cc14223253b50addb96dd054d02c3f7f2681ac.1440771116.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:34035 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbbH1Qck (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 12:32:40 -0400
Received: by pabzx8 with SMTP id zx8so67723477pab.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 09:32:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <21cc14223253b50addb96dd054d02c3f7f2681ac.1440771116.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 28, 2015 at 04:27:25PM +0200, Jiri Benc wrote:
> The mode field holds a single bit of information only (whether the
> ip_tunnel_info struct is for rx or tx). Change the mode field to bit flags.
> This allows more mode flags to be added.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>
