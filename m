From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH iproute2/net-next] tc: flower: Update dest UDP port
 documentation
Date: Mon, 9 Jan 2017 12:10:15 -0800
Message-ID: <20170109121015.3a147982@xeon-e3>
References: <1483527738-22087-1-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
        Dinan Gunawardena <dinan.gunawardena@netronome.com>,
        Hadar Hen Zion <hadarh@mellanox.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:32827 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751559AbdAIUKR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 15:10:17 -0500
Received: by mail-pg0-f41.google.com with SMTP id 204so24148695pge.0
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 12:10:17 -0800 (PST)
In-Reply-To: <1483527738-22087-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed,  4 Jan 2017 12:02:18 +0100
Simon Horman <simon.horman@netronome.com> wrote:

> Since 41aa17ff4668 ("tc/cls_flower: Add dest UDP port to tunnel params")
> tc flower supports setting the dest UDP port.
> 
> * Use "port_number" to be consistent with other man-page text
> * Re-add "enc_dst_port" documentation to manpage which was
>   accidently removed by b2a1f740aa4d ("tc: flower: document that *_ip
>   parameters take a PREFIX as an argument.")
> 
> Cc: Hadar Hen Zion <hadarh@mellanox.com>
> Signed-off-by: Simon Horman <simon.horman@netronome.com>

Applied to net-next
