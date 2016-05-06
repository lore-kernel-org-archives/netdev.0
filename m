From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2 0/2] ip link gre: fix external mode handling
Date: Fri, 6 May 2016 11:50:17 -0700
Message-ID: <20160506115017.1d1f21f9@xeon-e3>
References: <cover.1461766016.git.jbenc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Paolo Abeni <pabeni@redhat.com>,
	Pravin Shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33668 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758144AbcEFSuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 14:50:06 -0400
Received: by mail-pf0-f180.google.com with SMTP id 206so52814597pfu.0
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 11:50:06 -0700 (PDT)
In-Reply-To: <cover.1461766016.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 27 Apr 2016 16:11:12 +0200
Jiri Benc <jbenc@redhat.com> wrote:

> Fix two bugs with handling of the 'external' keyword for GRE.
> 
> Jiri Benc (2):
>   ip link gre: create interfaces in external mode correctly
>   ip link gre: print only relevant info in external mode
> 
>  ip/link_gre.c | 43 +++++++++++++++++++++++++------------------
>  1 file changed, 25 insertions(+), 18 deletions(-)
> 

Applied
