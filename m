From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 2/3] bpf: add xdpdrv for requesting XDP driver
 mode
Date: Tue, 27 Jun 2017 02:30:43 +0200
Message-ID: <5951A733.2070909@iogearbox.net>
References: <20170627002353.12292-1-jakub.kicinski@netronome.com> <20170627002353.12292-3-jakub.kicinski@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: oss-drivers@netronome.com
To: Jakub Kicinski <jakub.kicinski@netronome.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44230 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751453AbdF0Aap (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2017 20:30:45 -0400
In-Reply-To: <20170627002353.12292-3-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/27/2017 02:23 AM, Jakub Kicinski wrote:
> Allow user to select XDP DRV_MODE flag by using xdpdrv keyword
> instead of xdp or xdpgeneric.
>
> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
