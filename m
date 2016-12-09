From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v2 iproute2/net-next 2/3] tc: flower: introduce enum
 flower_endpoint
Date: Fri, 9 Dec 2016 12:47:51 -0800
Message-ID: <20161209124751.5fb5d3cc@xeon-e3>
References: <1481118843-10428-1-git-send-email-simon.horman@netronome.com>
        <1481118843-10428-3-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:35983 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751388AbcLIUry (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Dec 2016 15:47:54 -0500
Received: by mail-pg0-f44.google.com with SMTP id f188so11277399pgc.3
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2016 12:47:54 -0800 (PST)
In-Reply-To: <1481118843-10428-3-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  7 Dec 2016 14:54:02 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Introduce enum flower_endpoint and use it instead of a bool
> as the type for paramatising source and destination.
> 
> This is intended to improve read-ability and provide some type
> checking of endpoint parameters.
> 
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied to net-next
