From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net-next 1/2] l2tp: set name_assign_type for devices
 created by l2tp_eth.c
Date: Tue, 25 Apr 2017 11:40:13 +0100
Message-ID: <77bfc1d7-32fe-6fcf-4e57-5fa999611372@katalix.com>
References: <cover.1493035407.git.g.nault@alphalink.fr>
 <062e3c5c1c8b9d6ddea34de74e98c159f78a2f0b.1493035407.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Guillaume Nault <g.nault@alphalink.fr>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.katalix.com ([82.103.140.233]:41133 "EHLO mail.katalix.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1031494AbdDYKkQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 25 Apr 2017 06:40:16 -0400
In-Reply-To: <062e3c5c1c8b9d6ddea34de74e98c159f78a2f0b.1493035407.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/04/17 13:16, Guillaume Nault wrote:
> Export naming scheme used when creating l2tpeth interfaces
> (/sys/class/net/<iface>/name_assign_type). This let userspace know if
> the device's name has been generated automatically or defined manually.
>
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
Acked-by: James Chapman <jchapman@katalix.com>
