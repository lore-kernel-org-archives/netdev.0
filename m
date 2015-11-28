From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next 3/5] {f,m}_bpf: allow for user-defined
 object pinnings
Date: Sat, 28 Nov 2015 02:41:53 +0100
Message-ID: <56590661.4030702@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net> <7011752f729c16ef154b25753448365399a26793.1448541097.git.daniel@iogearbox.net> <5658F4C9.8090104@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:54127 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751219AbbK1BmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 20:42:00 -0500
In-Reply-To: <5658F4C9.8090104@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2015 01:26 AM, David Ahern wrote:
...
> seems like an unrelated change.

Nope, it's being reused from tc_bpf.c.
