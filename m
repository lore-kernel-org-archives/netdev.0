From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: WARN_ON running XDP on virtio net device
Date: Mon, 10 Apr 2017 16:33:02 -0600
Message-ID: <de78366a-998d-a27b-9042-77ee0d4ef56a@cumulusnetworks.com>
References: <9370d199-9a73-308c-97d0-8d473e8536b2@cumulusnetworks.com>
 <20170411003729-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: jasowang@redhat.com,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33470 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751593AbdDJWdF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Apr 2017 18:33:05 -0400
Received: by mail-pg0-f52.google.com with SMTP id x125so112534742pgb.0
        for <netdev@vger.kernel.org>; Mon, 10 Apr 2017 15:33:05 -0700 (PDT)
In-Reply-To: <20170411003729-mutt-send-email-mst@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/17 3:37 PM, Michael S. Tsirkin wrote:
> On Mon, Apr 10, 2017 at 03:21:53PM -0600, David Ahern wrote:
>> I'm hitting a WARN_ON running XDP with virtio net:
> I just sent a pull request. Would appreciate reports on whether
> it helps.
> 

it does.
