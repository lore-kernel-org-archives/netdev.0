From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 00/10] BPF updates
Date: Mon, 16 May 2016 20:07:36 +0200
Message-ID: <573A0C68.40603@iogearbox.net>
References: <cover.1463158442.git.daniel@iogearbox.net> <20160516.134959.1324414574261810210.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: alexei.starovoitov@gmail.com, elena.reshetova@intel.com,
	zlim.lnx@gmail.com, yang.shi@linaro.org,
	holzheu@linux.vnet.ibm.com, tgraf@suug.ch, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:45036 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750729AbcEPSHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 14:07:44 -0400
In-Reply-To: <20160516.134959.1324414574261810210.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/16/2016 07:49 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Fri, 13 May 2016 19:08:25 +0200
>
>> This set implements constant blinding for BPF, first couple of
>> patches are some preparatory cleanups, followed by the blinding.
>> Please see individual patches for details.
>
> Looks good, series applied.

Thanks!

> "BPF blinding" would have been a good Subject line. :)

Right, I'll get rid of this subject habit on my cover letters
in future.

Thanks,
Daniel
