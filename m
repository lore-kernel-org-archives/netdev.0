From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v5 14/17] dt-bindings: slave-device: add current-speed
 property
Date: Fri, 12 May 2017 19:05:38 -0500
Message-ID: <20170513000538.4vczi2qqr2hykv6g@rob-hp-laptop>
References: <1494406408-31760-1-git-send-email-stefan.wahren@i2se.com>
 <1494406408-31760-15-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Mark Rutland <mark.rutland@arm.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Jiri Slaby <jslaby@suse.com>, linux-serial@vger.kernel.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33347 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757786AbdEMAFk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 12 May 2017 20:05:40 -0400
Content-Disposition: inline
In-Reply-To: <1494406408-31760-15-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 10, 2017 at 10:53:25AM +0200, Stefan Wahren wrote:
> This adds a new DT property to define the current baud rate of the
> slave device.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  Documentation/devicetree/bindings/serial/slave-device.txt | 9 +++++++++
>  1 file changed, 9 insertions(+)

Reviewed-by: Rob Herring <robh@kernel.org>
