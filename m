From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 3/3] virtio: use kcalloc and kmalloc_array
Date: Tue, 26 Jul 2016 09:35:43 -0700
Message-ID: <20160726093543.1525924e@xeon-e3>
References: <20160726162008.310530368@networkplumber.org>
	<20160726162037.897138759@networkplumber.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:36290 "EHLO
	mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754198AbcGZQf3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 12:35:29 -0400
Received: by mail-pf0-f176.google.com with SMTP id h186so1362332pfg.3
        for <netdev@vger.kernel.org>; Tue, 26 Jul 2016 09:35:29 -0700 (PDT)
In-Reply-To: <20160726162037.897138759@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Jul 2016 09:20:11 -0700
Stephen Hemminger <stephen@networkplumber.org> wrote:

> Preferred style is to use kcalloc and kmalloc_array.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Do not apply, needs redo. Wasn't updated. properly
