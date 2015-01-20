From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH] net: ipv6: Make address flushing on ifdown optional
Date: Tue, 20 Jan 2015 10:07:21 -0700
Message-ID: <54BE8B49.5020609@gmail.com>
References: <1421263039-96198-1-git-send-email-dsahern@gmail.com> <1421679769.32277.15.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:60363 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752534AbbATRHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 12:07:22 -0500
Received: by mail-pd0-f175.google.com with SMTP id fl12so11171901pdb.6
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 09:07:22 -0800 (PST)
In-Reply-To: <1421679769.32277.15.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/19/15 8:02 AM, Hannes Frederic Sowa wrote:
>
> I would still prefer that we flush automatically generated addresses and
> only keep the static and permanent ones.
>
> What do you think?

Fine with me. Static addresses were the motivation of the patch.

David
