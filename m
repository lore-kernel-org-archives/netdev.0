From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 09/10] arm64: unexport set_memory_ro and set_memory_rw
Date: Sun, 01 Mar 2015 10:52:34 +0100
Message-ID: <54F2E162.9050604@iogearbox.net>
References: <cover.1425040939.git.daniel@iogearbox.net> <cb778076d2d089dd52605b8eaad3ee6097e61eae.1425040940.git.daniel@iogearbox.net> <20150227195443.GD24818@arm.com> <54F0CDF7.7060900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"ast@plumgrid.com" <ast@plumgrid.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Laura Abbott <lauraa@codeaurora.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Will Deacon <will.deacon@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54F0CDF7.7060900@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Will,

On 02/27/2015 09:05 PM, Daniel Borkmann wrote:
> On 02/27/2015 08:54 PM, Will Deacon wrote:
> ...
>> Looks good to me. Can this be applied independently, or does it need to
>> remain part of your series?
>
> Ideally, it should be seen as part of this series, but I have no problem
> if this one goes via arm64 tree, instead. What Dave and you prefer. ;)

I'll resend you this one directly as a stand-alone patch to arm64,
with Acked-by's preserved.

Thanks,
Daniel
