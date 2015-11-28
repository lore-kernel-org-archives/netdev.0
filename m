From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH iproute2 -next 3/5] {f,m}_bpf: allow for user-defined
 object pinnings
Date: Fri, 27 Nov 2015 23:03:22 -0700
Message-ID: <565943AA.8010200@cumulusnetworks.com>
References: <cover.1448541097.git.daniel@iogearbox.net>
 <7011752f729c16ef154b25753448365399a26793.1448541097.git.daniel@iogearbox.net>
 <5658F4C9.8090104@cumulusnetworks.com> <56590661.4030702@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34070 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750885AbbK1GD0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2015 01:03:26 -0500
Received: by padhx2 with SMTP id hx2so131345726pad.1
        for <netdev@vger.kernel.org>; Fri, 27 Nov 2015 22:03:25 -0800 (PST)
In-Reply-To: <56590661.4030702@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/27/15 6:41 PM, Daniel Borkmann wrote:
> On 11/28/2015 01:26 AM, David Ahern wrote:
> ...
>> seems like an unrelated change.
>
> Nope, it's being reused from tc_bpf.c.

ack. missed that earlier.
