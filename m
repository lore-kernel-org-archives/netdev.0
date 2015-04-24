From: Michael Chan <mchan@broadcom.com>
Subject: Re: [Problem] broadcom tg3 network driver disconnects under high
 load
Date: Fri, 24 Apr 2015 13:56:31 -0700
Message-ID: <1429908991.3920.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="cp1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Toan Pham <tpham3783@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:64060 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965408AbbDXU4i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Apr 2015 16:56:38 -0400
In-Reply-To: <CAGNmLEMbyR6-1WSyPRZQhLanH_UB7xb5cVVQ9N625bvdhbA6MA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-04-24 at 12:33 -0400, Toan Pham wrote: 
> Summary:  Broadcom 5762 NIC locks up under heavy load.

Can you provide lspci -vvvxxx -s 3:0.0

after it gets into this state?

Thanks.
