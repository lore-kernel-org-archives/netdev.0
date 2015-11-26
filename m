From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH iproute2 -next 1/5] {f,m}_bpf: make tail calls working
Date: Thu, 26 Nov 2015 15:40:11 +0100
Message-ID: <565719CB.7060501@iogearbox.net>
References: <cover.1448541097.git.daniel@iogearbox.net> <88d074dcdf1469ea381e1d732852cc87fb1aba2c.1448541097.git.daniel@iogearbox.net> <565704D4.8070201@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@kernel.org, netdev@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49674 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750964AbbKZOkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Nov 2015 09:40:13 -0500
In-Reply-To: <565704D4.8070201@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/26/2015 02:10 PM, Sergei Shtylyov wrote:
[...]
>     Isn't just *return* i; simpler? That way, you don't need 'ret' at all.

Okay, sure, fixed.

Thanks,
Daniel
