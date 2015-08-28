From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 1/4] ip_tunnels: convert the mode field of
 ip_tunnel_info to flags
Date: Sat, 29 Aug 2015 00:15:49 +0200
Message-ID: <20150828221549.GA32001@pox.localdomain>
References: <cover.1440787600.git.jbenc@redhat.com>
 <19c04b86fdfd059ec3b74f997b008702787e6450.1440787600.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:36811 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752695AbbH1WPv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Aug 2015 18:15:51 -0400
Received: by wicfv10 with SMTP id fv10so18206013wic.1
        for <netdev@vger.kernel.org>; Fri, 28 Aug 2015 15:15:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <19c04b86fdfd059ec3b74f997b008702787e6450.1440787600.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/28/15 at 08:48pm, Jiri Benc wrote:
> The mode field holds a single bit of information only (whether the
> ip_tunnel_info struct is for rx or tx). Change the mode field to bit flags.
> This allows more mode flags to be added.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>
> Acked-by: Alexei Starovoitov <ast@plumgrid.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
