From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: packet tracing
Date: Thu, 7 May 2015 08:26:55 +0200
Message-ID: <20150507062655.GB21015@haze>
References: <CABqzqi5f7JMY7MLXxeUn1_vdO9j0uL3-_eZ8fdp349rX1Kz7cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>
To: sainath grandhi <saiallforums@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:63936 "EHLO
	sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751954AbbEGGcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2015 02:32:11 -0400
Content-Disposition: inline
In-Reply-To: <CABqzqi5f7JMY7MLXxeUn1_vdO9j0uL3-_eZ8fdp349rX1Kz7cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 06, 2015 at 11:16:32PM -0700, sainath grandhi wrote:
> Hello,
>     Is there any debug message framework in place for tracking a
> network packet as it passes through different kernel stack layers
> (layer 3, layer 2, bridge devices, drivers etc)?

Try iptables LOG target
