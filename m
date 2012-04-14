From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Question about tlv message support and encoding
Date: Sat, 14 Apr 2012 10:03:02 -0700
Message-ID: <20120414100302.051c5298@nehalam.linuxnetplumber.net>
References: <CA+wR77pwetwv7W3r6EB261mMKAZj6npjNE_nnXKeTQSnfCwe7w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Spyros Gasteratos <spyrosgaster@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48131 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751233Ab2DNRDG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 13:03:06 -0400
In-Reply-To: <CA+wR77pwetwv7W3r6EB261mMKAZj6npjNE_nnXKeTQSnfCwe7w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 14 Apr 2012 19:18:16 +0300
Spyros Gasteratos <spyrosgaster@gmail.com> wrote:

> Hello everyone
> 
> Do you know if the kernel has any support for the construction and encoding
> of type/length/value (TLV) or other information element messages?
> if it has(or if you dont know) where can I find a list or more documentation?


netlink.h
