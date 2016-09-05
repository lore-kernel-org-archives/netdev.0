From: Gerard Garcia <ggarcia@abra.uab.cat>
Subject: Re: [PATCH v5] virtio-vsock: Add timer to handle OOM situations
Date: Mon, 5 Sep 2016 12:30:29 +0200
Message-ID: <f7998fa5-e0ed-d8f7-0443-a1e0f9058ad1@deic.uab.cat>
References: <20160812140208.16772-1-ggarcia@deic.uab.cat>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, mst@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35695 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932444AbcIEKac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Sep 2016 06:30:32 -0400
Received: by mail-wm0-f66.google.com with SMTP id a6so1348918wmc.2
        for <netdev@vger.kernel.org>; Mon, 05 Sep 2016 03:30:31 -0700 (PDT)
In-Reply-To: <20160812140208.16772-1-ggarcia@deic.uab.cat>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/12/2016 04:02 PM, ggarcia@deic.uab.cat wrote:
> From: Gerard Garcia <ggarcia@deic.uab.cat>
>
> Set up a rx timer to avoid packets being discarded when there is no
> available memory in the host.
>
> Signed-off-by: Gerard Garcia <ggarcia@deic.uab.cat>
> Reviewed-by: Stefan Hajnoczi <stefanha@redhat.com>
>

Seems that this patch and [PATCH v3] virtio-vsock: Fix unbound rx buffer 
weren't applied, is there something missing that needs to be fixed?
