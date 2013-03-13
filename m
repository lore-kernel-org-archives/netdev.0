From: Andre Heider <a.heider@gmail.com>
Subject: Re: [ 000/100] 3.8.3-stable review
Date: Wed, 13 Mar 2013 09:02:46 +0100
Message-ID: <CAHsu+b9O+JG=v6FgAEG4KOVDGScFiZYQm_nqXOQ9NSae3D3hwA@mail.gmail.com>
References: <20130312223122.884099393@linuxfoundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, stable@vger.kernel.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:62572 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583Ab3CMICq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 04:02:46 -0400
In-Reply-To: <20130312223122.884099393@linuxfoundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 12, 2013 at 11:30 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> This is the start of the stable review cycle for the 3.8.3 release.
> There are 100 patches in this series, all will be posted as a response
> to this one.  If anyone has any issues with these being applied, please
> let me know.

Hi,

I'm missing a drivers/net/ethernet/atheros/atl1c patch, namely "atl1c:
restore buffer state".
In fact, it seems the whole netdev stable patch queue is missing:
http://patchwork.ozlabs.org/bundle/davem/stable/?state=*

Unsure what the workflow is here, how are these supposed to make to stable?

Thanks,
Andre
