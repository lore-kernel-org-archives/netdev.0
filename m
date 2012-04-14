From: Spiridon Gasteratos <std07252@di.uoa.gr>
Subject: Re: Question about tlv message support and encoding
Date: Sat, 14 Apr 2012 20:30:43 +0300
Message-ID: <CA+wR77pJ8p9yGnre2ys91TRVrtx2q=fcUEZNpXv66pSkq0GRBQ@mail.gmail.com>
References: <CA+wR77pwetwv7W3r6EB261mMKAZj6npjNE_nnXKeTQSnfCwe7w@mail.gmail.com>
 <20120414100302.051c5298@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from msa.uoa.gr ([195.134.100.72]:51595 "EHLO msa.uoa.gr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752370Ab2DNSBs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Apr 2012 14:01:48 -0400
Received: from mail-ey0-f174.google.com (mail-ey0-f174.google.com [209.85.215.174])
	(authenticated bits=0)
	by msa.uoa.gr (8.14.1/8.14.1) with ESMTP id q3EHV4UG011082
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sat, 14 Apr 2012 20:31:04 +0300 (EEST)
Received: by eaaq12 with SMTP id q12so985736eaa.19
        for <netdev@vger.kernel.org>; Sat, 14 Apr 2012 10:31:03 -0700 (PDT)
In-Reply-To: <20120414100302.051c5298@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thank you

On Sat, Apr 14, 2012 at 8:03 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Sat, 14 Apr 2012 19:18:16 +0300
> Spyros Gasteratos <spyrosgaster@gmail.com> wrote:
>
>> Hello everyone
>>
>> Do you know if the kernel has any support for the construction and encoding
>> of type/length/value (TLV) or other information element messages?
>> if it has(or if you dont know) where can I find a list or more documentation?
>
>
> netlink.h
