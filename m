From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 09/10] arm64: unexport set_memory_ro and set_memory_rw
Date: Fri, 27 Feb 2015 21:05:11 +0100
Message-ID: <54F0CDF7.7060900@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net> <cb778076d2d089dd52605b8eaad3ee6097e61eae.1425040940.git.daniel@iogearbox.net> <20150227195443.GD24818@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Laura Abbott <lauraa@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43073 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbbB0UFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 15:05:18 -0500
In-Reply-To: <20150227195443.GD24818@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/27/2015 08:54 PM, Will Deacon wrote:
...
> Looks good to me. Can this be applied independently, or does it need to
> remain part of your series?

Ideally, it should be seen as part of this series, but I have no problem
if this one goes via arm64 tree, instead. What Dave and you prefer. ;)

Thanks,
Daniel
