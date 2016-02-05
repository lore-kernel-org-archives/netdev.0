From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2] geneve: add support for lwt tunnel creation
 and dst port selection
Date: Fri, 5 Feb 2016 11:58:25 +1100
Message-ID: <20160205115825.0cbbe801@samsung9>
References: <388837c1ee3c12535c34454b89f9e046e12ee4a2.1453988899.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Benc <jbenc@redhat.com>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:36787 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750975AbcBEA6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 19:58:34 -0500
Received: by mail-pa0-f49.google.com with SMTP id yy13so24367486pab.3
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 16:58:34 -0800 (PST)
In-Reply-To: <388837c1ee3c12535c34454b89f9e046e12ee4a2.1453988899.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Jan 2016 14:48:55 +0100
Paolo Abeni <pabeni@redhat.com> wrote:

> This change add the ability to create lwt/flow based/externally
> controlled geneve device and to select the udp destination port used
> by a full geneve tunnel.
> 
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied
