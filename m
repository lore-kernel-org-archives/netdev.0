From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH v2 net-next 05/13] ip_tunnels: use tos and ttl fields
 also for IPv6
Date: Wed, 19 Aug 2015 18:31:40 +0200
Message-ID: <20150819163140.GE3635@pox.localdomain>
References: <cover.1439978875.git.jbenc@redhat.com>
 <02b40d3d85ff8778d315629c7d1b4e8dc08ba130.1439978875.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:34940 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbbHSQbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 12:31:43 -0400
Received: by wicne3 with SMTP id ne3so125187179wic.0
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2015 09:31:41 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02b40d3d85ff8778d315629c7d1b4e8dc08ba130.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/15 at 12:09pm, Jiri Benc wrote:
> Rename the ipv4_tos and ipv4_ttl fields to just 'tos' and 'ttl', as they'll
> be used with IPv6 tunnels, too.
> 
> Signed-off-by: Jiri Benc <jbenc@redhat.com>

Acked-by: Thomas Graf <tgraf@suug.ch>
